import DeckDomain
import DeckServices

public protocol TimelineBusinessLogic: AnyObject, Sendable {
  func loadTimeline(_ request: TimelineModels.Load.Request) async
}

public final class TimelineInteractor: TimelineBusinessLogic {
  private let services: AppServices
  private let presenter: TimelinePresentationLogic

  public init(services: AppServices, presenter: TimelinePresentationLogic) {
    self.services = services
    self.presenter = presenter
  }

  public func loadTimeline(_ request: TimelineModels.Load.Request) async {
    guard let account = request.account else {
      await presenter.presentTimeline(.init(statuses: []))
      return
    }
    do {
      let statuses = try await services.api.fetchHomeTimeline(account: account)
      await presenter.presentTimeline(.init(statuses: statuses))
    } catch {
      await presenter.presentTimeline(.init(statuses: []))
    }
  }
}
