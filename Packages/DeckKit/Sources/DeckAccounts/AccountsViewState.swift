import Foundation
import DeckServices

@MainActor
final class AccountsViewState: ObservableObject, AccountsDisplayLogic {
  @Published var accounts: [AccountRow] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  func displayAccounts(_ viewModel: AccountsModels.Load.ViewModel) {
    accounts = viewModel.accounts
  }

  func displayAddedAccount(_ viewModel: AccountsModels.Add.ViewModel) {
    accounts.append(viewModel.account)
  }

  func displayError(_ viewModel: AccountsModels.ErrorState.ViewModel) {
    errorMessage = viewModel.message
  }

  func setLoading(_ isLoading: Bool) {
    self.isLoading = isLoading
  }
}
