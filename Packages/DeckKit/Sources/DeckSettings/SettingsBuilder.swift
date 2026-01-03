import SwiftUI
import DeckServices

public enum SettingsBuilder {
  public static func make(services: AppServices) -> some View {
    let state = SettingsViewState()
    let presenter = SettingsPresenter(view: state)
    let worker = SettingsWorker()
    let interactor = SettingsInteractor(presenter: presenter, worker: worker)
    return SettingsView(state: state, interactor: interactor)
  }
}
