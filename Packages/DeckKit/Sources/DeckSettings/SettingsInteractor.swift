import DeckDomain
import DeckServices

public protocol SettingsBusinessLogic: AnyObject, Sendable {
  func loadSettings(_ request: SettingsModels.Load.Request) async
  func saveSettings(_ request: SettingsModels.Save.Request) async
}

public final class SettingsInteractor: SettingsBusinessLogic {
  private let services: AppServices
  private let presenter: SettingsPresentationLogic

  public init(services: AppServices, presenter: SettingsPresentationLogic) {
    self.services = services
    self.presenter = presenter
  }

  public func loadSettings(_ request: SettingsModels.Load.Request) async {
    let settings = await services.storage.loadSettings()
    await presenter.presentSettings(.init(settings: settings))
  }

  public func saveSettings(_ request: SettingsModels.Save.Request) async {
    await services.storage.saveSettings(request.settings)
    await presenter.presentSettings(.init(settings: request.settings))
  }
}
