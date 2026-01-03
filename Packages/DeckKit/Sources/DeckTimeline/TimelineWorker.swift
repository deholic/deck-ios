import Foundation
import DeckServices

struct TimelineWorker {
  let accountStore: AccountStore
  let timelineService: TimelineServicing

  func loadAccounts() async throws -> [Account] {
    try await accountStore.loadAccounts()
  }

  func fetchTimeline(account: Account, sinceId: String?) async throws -> [TimelinePost] {
    try await timelineService.fetchTimeline(account: account, sinceId: sinceId)
  }

  func toggleFavorite(account: Account, postId: String, isFavorited: Bool) async throws {
    try await timelineService.toggleFavorite(account: account, postId: postId, isFavorited: isFavorited)
  }

  func toggleBoost(account: Account, postId: String, isBoosted: Bool) async throws {
    try await timelineService.toggleBoost(account: account, postId: postId, isBoosted: isBoosted)
  }

  func toggleBookmark(account: Account, postId: String, isBookmarked: Bool) async throws {
    try await timelineService.toggleBookmark(account: account, postId: postId, isBookmarked: isBookmarked)
  }

  func setReaction(account: Account, postId: String, reaction: String?) async throws {
    try await timelineService.setReaction(account: account, postId: postId, reaction: reaction)
  }

  func reply(account: Account, postId: String, text: String) async throws {
    try await timelineService.reply(account: account, postId: postId, text: text)
  }

  func streamTimeline(account: Account, latestId: @escaping @Sendable () -> String?) -> AsyncStream<[TimelinePost]> {
    AsyncStream { continuation in
      let task = Task {
        while !Task.isCancelled {
          do {
            let posts = try await fetchTimeline(account: account, sinceId: latestId())
            if !posts.isEmpty {
              continuation.yield(posts)
            }
          } catch {
            continuation.yield([])
          }
          try? await Task.sleep(for: .seconds(12))
        }
        continuation.finish()
      }
      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }
}
