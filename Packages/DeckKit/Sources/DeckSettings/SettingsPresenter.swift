@MainActor
public protocol SettingsPresentationLogic: AnyObject, Sendable {
  func presentSettings(_ response: SettingsModels.Load.Response)
}

@MainActor
public final class SettingsPresenter: SettingsPresentationLogic {
  public weak var displayLogic: SettingsDisplayLogic?

  public init() {}

  public func presentSettings(_ response: SettingsModels.Load.Response) {
    displayLogic?.displaySettings(.init(settings: response.settings))
  }
}
