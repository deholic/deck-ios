import SwiftUI
import DeckServices

public enum TimelineBuilder {
  public static func make(services: AppServices) -> some View {
    let state = TimelineViewState()
    let presenter = TimelinePresenter(view: state)
    let worker = TimelineWorker(accountStore: services.accountStore, timelineService: services.timelineService)
    let interactor = TimelineInteractor(presenter: presenter, worker: worker)
    return TimelineView(state: state, interactor: interactor)
  }
}
