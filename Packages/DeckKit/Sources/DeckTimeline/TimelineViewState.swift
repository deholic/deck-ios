import Foundation

@MainActor
protocol TimelineDisplayLogic: AnyObject {
  func displayTimeline(_ viewModel: TimelineModels.Load.ViewModel)
  func displayError(_ viewModel: TimelineModels.ErrorState.ViewModel)
  func setLoading(_ isLoading: Bool)
}

@MainActor
final class TimelineViewState: ObservableObject, TimelineDisplayLogic {
  @Published var accounts: [TimelineAccountViewModel] = []
  @Published var posts: [TimelinePostViewModel] = []
  @Published var selectedAccountId: UUID?
  @Published var isLoading = false
  @Published var isStreaming = false
  @Published var errorMessage: String?

  func displayTimeline(_ viewModel: TimelineModels.Load.ViewModel) {
    accounts = viewModel.accounts
    posts = viewModel.posts
    selectedAccountId = viewModel.selectedAccountId
    isStreaming = viewModel.isStreaming
  }

  func displayError(_ viewModel: TimelineModels.ErrorState.ViewModel) {
    errorMessage = viewModel.message
  }

  func setLoading(_ isLoading: Bool) {
    self.isLoading = isLoading
  }
}
