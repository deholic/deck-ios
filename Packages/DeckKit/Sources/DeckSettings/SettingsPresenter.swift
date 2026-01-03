import Foundation

@MainActor
final class SettingsPresenter: SettingsPresentationLogic {
  private weak var view: SettingsDisplayLogic?

  init(view: SettingsDisplayLogic) {
    self.view = view
  }

  func presentSettings(_ response: SettingsModels.Load.Response) {
    let viewModel = SettingsModels.Load.ViewModel(settings: .init(settings: response.settings))
    view?.displaySettings(viewModel)
  }

  func presentUpdatedSettings(_ response: SettingsModels.Update.Response) {
    let viewModel = SettingsModels.Update.ViewModel(settings: .init(settings: response.settings))
    view?.displayUpdatedSettings(viewModel)
  }

  func presentError(_ message: String) {
    view?.displayError(SettingsModels.ErrorState.ViewModel(message: message))
  }

  func setLoading(_ isLoading: Bool) {
    view?.setLoading(isLoading)
  }
}
