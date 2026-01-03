@MainActor
public protocol TimelinePresentationLogic: AnyObject, Sendable {
  func presentTimeline(_ response: TimelineModels.Load.Response)
}

@MainActor
public final class TimelinePresenter: TimelinePresentationLogic {
  public weak var displayLogic: TimelineDisplayLogic?

  public init() {}

  public func presentTimeline(_ response: TimelineModels.Load.Response) {
    displayLogic?.displayTimeline(.init(statuses: response.statuses))
  }
}
