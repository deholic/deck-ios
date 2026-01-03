import SwiftUI
import DeckServices

public enum ComposeBuilder {
  public static func make(services: AppServices) -> some View {
    let state = ComposeViewState()
    let presenter = ComposePresenter(view: state)
    let worker = ComposeWorker(accountStore: services.accountStore, postingService: services.postingService)
    let interactor = ComposeInteractor(presenter: presenter, worker: worker)
    return ComposeView(state: state, interactor: interactor)
  }
}
