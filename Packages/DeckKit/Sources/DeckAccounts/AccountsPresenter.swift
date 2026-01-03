import Foundation
import DeckServices

@MainActor
final class AccountsPresenter: AccountsPresentationLogic {
  private weak var view: AccountsDisplayLogic?

  init(view: AccountsDisplayLogic) {
    self.view = view
  }

  func presentAccounts(_ response: AccountsModels.Load.Response) {
    let viewModel = AccountsModels.Load.ViewModel(accounts: response.accounts.map(AccountRow.init))
    view?.displayAccounts(viewModel)
  }

  func presentAddedAccount(_ response: AccountsModels.Add.Response) {
    let viewModel = AccountsModels.Add.ViewModel(account: AccountRow(account: response.account))
    view?.displayAddedAccount(viewModel)
  }

  func presentError(_ message: String) {
    view?.displayError(AccountsModels.ErrorState.ViewModel(message: message))
  }

  func setLoading(_ isLoading: Bool) {
    view?.setLoading(isLoading)
  }
}
