import Foundation
import DeckServices

@MainActor
protocol AccountsBusinessLogic {
  func loadAccounts() async
  func removeAccount(id: String) async
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

@MainActor
final class AccountsInteractor: AccountsBusinessLogic {
  private let presenter: AccountsPresentationLogic
  private let worker: AccountsWorker
  private let parser = InstanceURLParser()

  init(presenter: AccountsPresentationLogic, worker: AccountsWorker) {
    self.presenter = presenter
    self.worker = worker
  }

  func loadAccounts() async {
    presenter.setLoading(true)
    defer { presenter.setLoading(false) }
    do {
      let accounts = try await worker.loadAccounts()
      presenter.presentAccounts(.init(accounts: accounts))
    } catch {
      presenter.presentError(error.localizedDescription)
    }
  }

  func removeAccount(id: String) async {
    presenter.setLoading(true)
    defer { presenter.setLoading(false) }
    do {
      try await worker.removeAccount(id: id)
      let accounts = try await worker.loadAccounts()
      presenter.presentAccounts(.init(accounts: accounts))
    } catch {
      presenter.presentError(error.localizedDescription)
    }
  }

  func startAuthentication(service: AccountServiceType, instance: String) async -> AuthSession? {
    guard let instanceURL = parser.parse(instance) else {
      presenter.presentError(AuthenticationError.invalidInstance.localizedDescription)
      return nil
    }

    presenter.setLoading(true)
    defer { presenter.setLoading(false) }
    do {
      return try await worker.startAuthentication(service: service, instance: instanceURL)
    } catch {
      presenter.presentError(error.localizedDescription)
      return nil
    }
  }

  func finishAuthentication(session: AuthSession, callbackURL: URL) async {
    presenter.setLoading(true)
    defer { presenter.setLoading(false) }
    do {
      let account = try await worker.finishAuthentication(session: session, callbackURL: callbackURL)
      presenter.presentAddedAccount(.init(account: account))
    } catch {
      presenter.presentError(error.localizedDescription)
    }
  }
}
