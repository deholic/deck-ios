import Foundation

@MainActor
final class ComposePresenter: ComposePresentationLogic {
  private weak var view: ComposeDisplayLogic?

  init(view: ComposeDisplayLogic) {
    self.view = view
  }

  func presentAccounts(_ response: ComposeModels.Load.Response) {
    let rows = response.accounts.map(ComposeAccountRow.init)
    let selectedAccountId = rows.first?.id
    view?.displayAccounts(.init(accounts: rows, selectedAccountId: selectedAccountId))
  }

  func presentSubmitSuccess(_ response: ComposeModels.Submit.Response) {
    view?.displaySubmitSuccess(.init(message: response.message))
  }

  func presentError(_ message: String) {
    view?.displayError(.init(message: message))
  }

  func setLoading(_ isLoading: Bool) {
    view?.setLoading(isLoading)
  }
}
