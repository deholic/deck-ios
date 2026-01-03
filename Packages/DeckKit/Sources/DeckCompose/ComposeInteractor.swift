import Foundation
import DeckServices

protocol ComposeBusinessLogic {
  func loadAccounts() async
  func submitPost(_ request: ComposeModels.Submit.Request) async
}

@MainActor
protocol ComposePresentationLogic: AnyObject {
  func presentAccounts(_ response: ComposeModels.Load.Response)
  func presentSubmitSuccess(_ response: ComposeModels.Submit.Response)
  func presentError(_ message: String)
  func setLoading(_ isLoading: Bool)
}

@MainActor
protocol ComposeDisplayLogic: AnyObject {
  func displayAccounts(_ viewModel: ComposeModels.Load.ViewModel)
  func displaySubmitSuccess(_ viewModel: ComposeModels.Submit.ViewModel)
  func displayError(_ viewModel: ComposeModels.ErrorState.ViewModel)
  func setLoading(_ isLoading: Bool)
}

@MainActor
final class ComposeInteractor: ComposeBusinessLogic {
  private let presenter: ComposePresentationLogic
  private let worker: ComposeWorker
  private var accounts: [Account] = []

  init(presenter: ComposePresentationLogic, worker: ComposeWorker) {
    self.presenter = presenter
    self.worker = worker
  }

  func loadAccounts() async {
    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      accounts = try await worker.loadAccounts()
      await presenter.presentAccounts(.init(accounts: accounts))
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func submitPost(_ request: ComposeModels.Submit.Request) async {
    let trimmed = request.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      await presenter.presentError("Enter some text to post.")
      return
    }
    guard let accountId = request.accountId else {
      await presenter.presentError("Select an account to post from.")
      return
    }
    guard let account = accounts.first(where: { $0.id == accountId }) else {
      await presenter.presentError("Selected account is unavailable.")
      return
    }

    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      try await worker.createPost(account: account, text: trimmed, visibility: request.visibility)
      await presenter.presentSubmitSuccess(.init(message: "Posted successfully."))
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }
}
