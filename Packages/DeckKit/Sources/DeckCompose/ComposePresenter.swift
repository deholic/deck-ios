@MainActor
public protocol ComposePresentationLogic: AnyObject, Sendable {
  func presentPost(_ response: ComposeModels.Post.Response)
}

@MainActor
public final class ComposePresenter: ComposePresentationLogic {
  public weak var displayLogic: ComposeDisplayLogic?

  public init() {}

  public func presentPost(_ response: ComposeModels.Post.Response) {
    displayLogic?.displayPost(.init(didPost: response.status != nil))
  }
}
