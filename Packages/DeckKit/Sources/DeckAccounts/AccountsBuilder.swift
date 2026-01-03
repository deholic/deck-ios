import SwiftUI
import DeckServices

public enum AccountsBuilder {
  public static func make(services: AppServices) -> some View {
    let state = AccountsViewState()
    let presenter = AccountsPresenter(view: state)
    let worker = AccountsWorker(accountStore: services.accountStore, authenticationService: services.authenticationService)
    let interactor = AccountsInteractor(presenter: presenter, worker: worker)
    return AccountsView(state: state, interactor: interactor)
  }
}
