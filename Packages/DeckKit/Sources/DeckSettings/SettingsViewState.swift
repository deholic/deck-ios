import Foundation

@MainActor
final class SettingsViewState: ObservableObject, SettingsDisplayLogic {
  @Published var theme: ThemeOption = SettingsModels.Settings.default.theme
  @Published var refreshInterval: Int = SettingsModels.Settings.default.refreshInterval
  @Published var autoplayVideos: Bool = SettingsModels.Settings.default.autoplayVideos
  @Published var hapticsEnabled: Bool = SettingsModels.Settings.default.hapticsEnabled
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var isReady = false

  func displaySettings(_ viewModel: SettingsModels.Load.ViewModel) {
    apply(viewModel.settings)
    isReady = true
  }

  func displayUpdatedSettings(_ viewModel: SettingsModels.Update.ViewModel) {
    apply(viewModel.settings)
  }

  func displayError(_ viewModel: SettingsModels.ErrorState.ViewModel) {
    errorMessage = viewModel.message
  }

  func setLoading(_ isLoading: Bool) {
    self.isLoading = isLoading
  }

  private func apply(_ settings: SettingsModels.SettingsViewModel) {
    theme = settings.theme
    refreshInterval = settings.refreshInterval
    autoplayVideos = settings.autoplayVideos
    hapticsEnabled = settings.hapticsEnabled
  }
}
