import Foundation
import DeckServices

@MainActor
protocol TimelinePresentationLogic: AnyObject {
  func presentTimeline(_ response: TimelineModels.Load.Response)
  func presentError(_ message: String)
  func setLoading(_ isLoading: Bool)
}

@MainActor
final class TimelinePresenter: TimelinePresentationLogic {
  private weak var view: TimelineDisplayLogic?
  private let dateFormatter: RelativeDateTimeFormatter

  init(view: TimelineDisplayLogic) {
    self.view = view
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    self.dateFormatter = formatter
  }

  func presentTimeline(_ response: TimelineModels.Load.Response) {
    let accounts = response.accounts.map { account in
      TimelineAccountViewModel(
        id: account.id,
        title: account.username,
        subtitle: "\(account.service.displayName) · \(account.instance.host ?? account.instance.absoluteString)"
      )
    }

    let posts = response.posts.map { post in
      TimelinePostViewModel(
        id: post.id,
        service: post.service,
        authorName: post.author.displayName,
        authorHandle: post.author.handle,
        avatarURL: post.author.avatarURL,
        content: post.content,
        createdAt: dateFormatter.localizedString(for: post.createdAt, relativeTo: Date()),
        boostedBy: post.boostedBy,
        replyCount: post.metrics.replies,
        boostCount: post.metrics.boosts,
        favoriteCount: post.metrics.favorites,
        reactions: post.reactions.map { reaction in
          TimelineReactionViewModel(id: reaction.id, name: reaction.name, count: reaction.count, isMine: reaction.isMine)
        },
        isBoosted: post.actions.isBoosted,
        isFavorited: post.actions.isFavorited,
        isBookmarked: post.actions.isBookmarked,
        canReact: post.service == .misskey,
        url: post.url
      )
    }

    view?.displayTimeline(.init(accounts: accounts, posts: posts, selectedAccountId: response.selectedAccountId, isStreaming: response.isStreaming))
  }

  func presentError(_ message: String) {
    view?.displayError(.init(message: message))
  }

  func setLoading(_ isLoading: Bool) {
    view?.setLoading(isLoading)
  }
}
