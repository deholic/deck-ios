import SwiftUI
import DeckDomain
import DeckServices

@MainActor
public protocol ComposeDisplayLogic: AnyObject {
  func displayPost(_ viewModel: ComposeModels.Post.ViewModel)
}

@MainActor
public final class ComposeViewModel: ObservableObject, ComposeDisplayLogic {
  @Published public var content: String = ""
  @Published public var visibility: DeckDomain.Visibility = .public
  @Published public var contentWarning: String = ""
  @Published public var didPost: Bool = false

  public var account: Account?
  private let interactor: ComposeBusinessLogic

  public init(account: Account? = nil, interactor: ComposeBusinessLogic) {
    self.account = account
    self.interactor = interactor
  }

  public func post() {
    Task {
      await interactor.postStatus(.init(
        account: account,
        content: content,
        visibility: visibility,
        contentWarning: contentWarning.isEmpty ? nil : contentWarning
      ))
    }
  }

  public func displayPost(_ viewModel: ComposeModels.Post.ViewModel) {
    didPost = viewModel.didPost
    if viewModel.didPost {
      content = ""
      contentWarning = ""
    }
  }
}

public struct ComposeView: View {
  @StateObject private var viewModel: ComposeViewModel

  public init(viewModel: ComposeViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      Form {
        Section("Content") {
          TextField("What's happening?", text: $viewModel.content, axis: .vertical)
        }
        Section("Visibility") {
          Picker("Visibility", selection: $viewModel.visibility) {
            Text("Public").tag(DeckDomain.Visibility.public)
            Text("Unlisted").tag(DeckDomain.Visibility.unlisted)
            Text("Followers").tag(DeckDomain.Visibility.followers)
            Text("Direct").tag(DeckDomain.Visibility.direct)
          }
        }
        Section("Content Warning") {
          TextField("Warning", text: $viewModel.contentWarning)
        }
        Button("Post") {
          viewModel.post()
        }
        .disabled(viewModel.content.isEmpty)
      }
      .navigationTitle("Compose")
      .alert("Posted", isPresented: $viewModel.didPost) {
        Button("OK", role: .cancel) {}
      }
    }
  }
}

@MainActor
public enum ComposeBuilder {
  public static func make(services: AppServices, account: Account? = nil) -> ComposeView {
    let presenter = ComposePresenter()
    let interactor = ComposeInteractor(services: services, presenter: presenter)
    let viewModel = ComposeViewModel(account: account, interactor: interactor)
    presenter.displayLogic = viewModel
    return ComposeView(viewModel: viewModel)
  }
}
