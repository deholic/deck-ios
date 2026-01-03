import Foundation
import DeckServices

final class ComposeWorker {
  private let accountStore: AccountStore
  private let postingService: PostingServicing

  init(accountStore: AccountStore, postingService: PostingServicing) {
    self.accountStore = accountStore
    self.postingService = postingService
  }

  func loadAccounts() async throws -> [Account] {
    try await accountStore.loadAccounts()
  }

  func createPost(account: Account, text: String, visibility: PostingVisibility) async throws {
    try await postingService.createPost(account: account, text: text, visibility: visibility)
  }
}
