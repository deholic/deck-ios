import Foundation
import DeckServices

protocol TimelineBusinessLogic {
  func load() async
  func refresh() async
  func selectAccount(id: UUID) async
  func toggleFavorite(postId: String) async
  func toggleBoost(postId: String) async
  func toggleBookmark(postId: String) async
  func setReaction(postId: String, reaction: String) async
  func clearReaction(postId: String) async
  func reply(_ request: TimelineModels.Reply.Request) async
}

@MainActor
final class TimelineInteractor: TimelineBusinessLogic {
  private let presenter: TimelinePresentationLogic
  private let worker: TimelineWorker
  private var accounts: [Account] = []
  private var posts: [TimelinePost] = []
  private var selectedAccountId: UUID?
  private var streamTask: Task<Void, Never>?

  init(presenter: TimelinePresentationLogic, worker: TimelineWorker) {
    self.presenter = presenter
    self.worker = worker
  }

  func load() async {
    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      accounts = try await worker.loadAccounts()
      selectedAccountId = accounts.first?.id
      posts = []
      await presenter.presentTimeline(.init(accounts: accounts, posts: posts, selectedAccountId: selectedAccountId, isStreaming: false))
      await refresh()
      startStreaming()
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func refresh() async {
    guard let account = selectedAccount else { return }
    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      posts = try await worker.fetchTimeline(account: account, sinceId: nil)
      await presenter.presentTimeline(.init(accounts: accounts, posts: posts, selectedAccountId: selectedAccountId, isStreaming: streamTask != nil))
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func selectAccount(id: UUID) async {
    guard selectedAccountId != id else { return }
    selectedAccountId = id
    posts = []
    await presenter.presentTimeline(.init(accounts: accounts, posts: posts, selectedAccountId: selectedAccountId, isStreaming: false))
    await refresh()
    startStreaming()
  }

  func toggleFavorite(postId: String) async {
    guard let account = selectedAccount, let index = posts.firstIndex(where: { $0.id == postId }) else { return }
    let post = posts[index]
    let isFavorited = post.actions.isFavorited
    updatePost(postId: postId) { post in
      let favorites = max(0, post.metrics.favorites + (isFavorited ? -1 : 1))
      return TimelinePost(
        id: post.id,
        service: post.service,
        author: post.author,
        content: post.content,
        createdAt: post.createdAt,
        url: post.url,
        boostedBy: post.boostedBy,
        metrics: TimelineMetrics(replies: post.metrics.replies, boosts: post.metrics.boosts, favorites: favorites),
        actions: TimelineActionState(isBoosted: post.actions.isBoosted, isFavorited: !isFavorited, isBookmarked: post.actions.isBookmarked),
        reactions: post.reactions
      )
    }
    do {
      try await worker.toggleFavorite(account: account, postId: postId, isFavorited: isFavorited)
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func toggleBoost(postId: String) async {
    guard let account = selectedAccount, let index = posts.firstIndex(where: { $0.id == postId }) else { return }
    let post = posts[index]
    let isBoosted = post.actions.isBoosted
    updatePost(postId: postId) { post in
      let boosts = max(0, post.metrics.boosts + (isBoosted ? -1 : 1))
      return TimelinePost(
        id: post.id,
        service: post.service,
        author: post.author,
        content: post.content,
        createdAt: post.createdAt,
        url: post.url,
        boostedBy: post.boostedBy,
        metrics: TimelineMetrics(replies: post.metrics.replies, boosts: boosts, favorites: post.metrics.favorites),
        actions: TimelineActionState(isBoosted: !isBoosted, isFavorited: post.actions.isFavorited, isBookmarked: post.actions.isBookmarked),
        reactions: post.reactions
      )
    }
    do {
      try await worker.toggleBoost(account: account, postId: postId, isBoosted: isBoosted)
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func toggleBookmark(postId: String) async {
    guard let account = selectedAccount, let index = posts.firstIndex(where: { $0.id == postId }) else { return }
    let post = posts[index]
    let isBookmarked = post.actions.isBookmarked
    updatePost(postId: postId) { post in
      TimelinePost(
        id: post.id,
        service: post.service,
        author: post.author,
        content: post.content,
        createdAt: post.createdAt,
        url: post.url,
        boostedBy: post.boostedBy,
        metrics: post.metrics,
        actions: TimelineActionState(isBoosted: post.actions.isBoosted, isFavorited: post.actions.isFavorited, isBookmarked: !isBookmarked),
        reactions: post.reactions
      )
    }
    do {
      try await worker.toggleBookmark(account: account, postId: postId, isBookmarked: isBookmarked)
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func setReaction(postId: String, reaction: String) async {
    await updateReaction(postId: postId, reaction: reaction)
  }

  func clearReaction(postId: String) async {
    await updateReaction(postId: postId, reaction: nil)
  }

  private func updateReaction(postId: String, reaction: String?) async {
    guard let account = selectedAccount else { return }
    updatePost(postId: postId) { post in
      guard post.service == .misskey else { return post }
      var reactions = post.reactions
      if let reaction {
        let index = reactions.firstIndex(where: { $0.name == reaction })
        if let index {
          let updated = TimelineReaction(name: reaction, count: reactions[index].count + 1, isMine: true)
          reactions[index] = updated
        } else {
          reactions.append(TimelineReaction(name: reaction, count: 1, isMine: true))
        }
      } else {
        if let index = reactions.firstIndex(where: { $0.isMine }) {
          let name = reactions[index].name
          let count = max(0, reactions[index].count - 1)
          reactions[index] = TimelineReaction(name: name, count: count, isMine: false)
        }
      }
      reactions = reactions.sorted { $0.name < $1.name }
      return TimelinePost(
        id: post.id,
        service: post.service,
        author: post.author,
        content: post.content,
        createdAt: post.createdAt,
        url: post.url,
        boostedBy: post.boostedBy,
        metrics: post.metrics,
        actions: post.actions,
        reactions: reactions
      )
    }
    do {
      try await worker.setReaction(account: account, postId: postId, reaction: reaction)
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func reply(_ request: TimelineModels.Reply.Request) async {
    let trimmed = request.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      await presenter.presentError("Enter a reply.")
      return
    }
    guard let account = selectedAccount else { return }
    do {
      try await worker.reply(account: account, postId: request.postId, text: trimmed)
      updatePost(postId: request.postId) { post in
        TimelinePost(
          id: post.id,
          service: post.service,
          author: post.author,
          content: post.content,
          createdAt: post.createdAt,
          url: post.url,
          boostedBy: post.boostedBy,
          metrics: TimelineMetrics(replies: post.metrics.replies + 1, boosts: post.metrics.boosts, favorites: post.metrics.favorites),
          actions: post.actions,
          reactions: post.reactions
        )
      }
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  private var selectedAccount: Account? {
    guard let selectedAccountId else { return nil }
    return accounts.first { $0.id == selectedAccountId }
  }

  private func startStreaming() {
    streamTask?.cancel()
    guard let account = selectedAccount else { return }
    streamTask = Task { [weak self] in
      guard let self else { return }
      let stream = worker.streamTimeline(account: account) { [weak self] in
        self?.posts.first?.id
      }
      await presenter.presentTimeline(.init(accounts: accounts, posts: posts, selectedAccountId: selectedAccountId, isStreaming: true))
      for await newPosts in stream {
        guard !newPosts.isEmpty else { continue }
        let combined = (newPosts + posts).uniqueById()
        posts = combined
        await presenter.presentTimeline(.init(accounts: accounts, posts: posts, selectedAccountId: selectedAccountId, isStreaming: true))
      }
    }
  }

  private func updatePost(postId: String, transform: (TimelinePost) -> TimelinePost) {
    guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
    posts[index] = transform(posts[index])
    Task { await presenter.presentTimeline(.init(accounts: accounts, posts: posts, selectedAccountId: selectedAccountId, isStreaming: streamTask != nil)) }
  }
}

private extension Array where Element == TimelinePost {
  func uniqueById() -> [TimelinePost] {
    var seen = Set<String>()
    return filter { post in
      guard !seen.contains(post.id) else { return false }
      seen.insert(post.id)
      return true
    }
  }
}
