import Foundation
import DeckServices

@MainActor
final class ComposeViewState: ObservableObject, ComposeDisplayLogic {
  @Published var accounts: [ComposeAccountRow] = []
  @Published var selectedAccountId: UUID?
  @Published var text: String = ""
  @Published var visibility: PostingVisibility = .public
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var successMessage: String?

  func displayAccounts(_ viewModel: ComposeModels.Load.ViewModel) {
    accounts = viewModel.accounts
    if selectedAccountId == nil {
      selectedAccountId = viewModel.selectedAccountId
    }
  }

  func displaySubmitSuccess(_ viewModel: ComposeModels.Submit.ViewModel) {
    successMessage = viewModel.message
    text = ""
  }

  func displayError(_ viewModel: ComposeModels.ErrorState.ViewModel) {
    errorMessage = viewModel.message
  }

  func setLoading(_ isLoading: Bool) {
    self.isLoading = isLoading
  }
}
