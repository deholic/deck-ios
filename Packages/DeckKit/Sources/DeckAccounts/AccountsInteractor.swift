import Foundation
import DeckServices

protocol AccountsBusinessLogic {
  func loadAccounts() async
  func removeAccount(id: UUID) async
  func startAuthentication(service: AccountServiceType, instance: String) async -> AuthSession?
  func finishAuthentication(session: AuthSession, callbackURL: URL) async
}

@MainActor
protocol AccountsPresentationLogic: AnyObject {
  func presentAccounts(_ response: AccountsModels.Load.Response)
  func presentAddedAccount(_ response: AccountsModels.Add.Response)
  func presentError(_ message: String)
  func setLoading(_ isLoading: Bool)
}

@MainActor
protocol AccountsDisplayLogic: AnyObject {
  func displayAccounts(_ viewModel: AccountsModels.Load.ViewModel)
  func displayAddedAccount(_ viewModel: AccountsModels.Add.ViewModel)
  func displayError(_ viewModel: AccountsModels.ErrorState.ViewModel)
  func setLoading(_ isLoading: Bool)
}

final class AccountsInteractor: AccountsBusinessLogic {
  private let presenter: AccountsPresentationLogic
  private let worker: AccountsWorker
  private let parser = InstanceURLParser()

  init(presenter: AccountsPresentationLogic, worker: AccountsWorker) {
    self.presenter = presenter
    self.worker = worker
  }

  func loadAccounts() async {
    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      let accounts = try await worker.loadAccounts()
      await presenter.presentAccounts(.init(accounts: accounts))
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func removeAccount(id: UUID) async {
    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      try await worker.removeAccount(id: id)
      let accounts = try await worker.loadAccounts()
      await presenter.presentAccounts(.init(accounts: accounts))
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func startAuthentication(service: AccountServiceType, instance: String) async -> AuthSession? {
    guard let instanceURL = parser.parse(instance) else {
      await presenter.presentError(AuthenticationError.invalidInstance.localizedDescription)
      return nil
    }

    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      return try await worker.startAuthentication(service: service, instance: instanceURL)
    } catch {
      await presenter.presentError(error.localizedDescription)
      return nil
    }
  }

  func finishAuthentication(session: AuthSession, callbackURL: URL) async {
    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      let account = try await worker.finishAuthentication(session: session, callbackURL: callbackURL)
      await presenter.presentAddedAccount(.init(account: account))
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }
}
