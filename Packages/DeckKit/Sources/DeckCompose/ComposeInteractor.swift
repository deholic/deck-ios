import DeckDomain
import DeckServices

public protocol ComposeBusinessLogic: AnyObject, Sendable {
  func postStatus(_ request: ComposeModels.Post.Request) async
}

public final class ComposeInteractor: ComposeBusinessLogic {
  private let services: AppServices
  private let presenter: ComposePresentationLogic

  public init(services: AppServices, presenter: ComposePresentationLogic) {
    self.services = services
    self.presenter = presenter
  }

  public func postStatus(_ request: ComposeModels.Post.Request) async {
    guard let account = request.account, !request.content.isEmpty else {
      await presenter.presentPost(.init(status: nil))
      return
    }
    do {
      let status = try await services.api.postStatus(
        account: account,
        content: request.content,
        visibility: request.visibility,
        attachments: [],
        contentWarning: request.contentWarning
      )
      await presenter.presentPost(.init(status: status))
    } catch {
      await presenter.presentPost(.init(status: nil))
    }
  }
}
