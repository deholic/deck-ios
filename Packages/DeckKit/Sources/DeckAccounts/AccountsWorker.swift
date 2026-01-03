import Foundation
import DeckServices

final class AccountsWorker: Sendable {
  private let accountStore: AccountStore
  private let authenticationService: AccountAuthenticationServicing

  init(accountStore: AccountStore, authenticationService: AccountAuthenticationServicing) {
    self.accountStore = accountStore
    self.authenticationService = authenticationService
  }

  func loadAccounts() async throws -> [Account] {
    try await accountStore.loadAccounts()
  }

  func removeAccount(id: String) async throws {
    try await accountStore.removeAccount(id: id)
  }

  func startAuthentication(service: AccountServiceType, instance: URL) async throws -> AuthSession {
    try await authenticationService.startAuthentication(service: service, instance: instance)
  }

  func finishAuthentication(session: AuthSession, callbackURL: URL) async throws -> Account {
    let account = try await authenticationService.finishAuthentication(session: session, callbackURL: callbackURL)
    try await accountStore.addAccount(account)
    return account
  }
}
