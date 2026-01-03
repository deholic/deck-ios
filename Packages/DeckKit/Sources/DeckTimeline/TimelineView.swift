import SwiftUI
import DeckDomain
import DeckServices
import DeckSharedUI

@MainActor
public protocol TimelineDisplayLogic: AnyObject {
  func displayTimeline(_ viewModel: TimelineModels.Load.ViewModel)
}

@MainActor
public final class TimelineViewModel: ObservableObject, TimelineDisplayLogic {
  @Published public var statuses: [Status] = []
  @Published public var errorMessage: String?
  public var account: Account?
  private let interactor: TimelineBusinessLogic

  public init(account: Account? = nil, interactor: TimelineBusinessLogic) {
    self.account = account
    self.interactor = interactor
  }

  public func load() {
    Task {
      await interactor.loadTimeline(.init(account: account))
    }
  }

  public func displayTimeline(_ viewModel: TimelineModels.Load.ViewModel) {
    statuses = viewModel.statuses
  }
}

public struct TimelineView: View {
  @StateObject private var viewModel: TimelineViewModel

  public init(viewModel: TimelineViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      Group {
        if viewModel.statuses.isEmpty {
          EmptyStateView(title: "No posts yet", subtitle: "Connect an account to load your home timeline.")
        } else {
          List(viewModel.statuses) { status in
            VStack(alignment: .leading, spacing: 6) {
              Text(status.author.username)
                .font(.headline)
              Text(status.content)
                .font(.body)
                .lineLimit(3)
            }
          }
          .listStyle(.plain)
        }
      }
      .navigationTitle("Timeline")
      .toolbar {
        Button("Refresh") {
          viewModel.load()
        }
      }
      .onAppear {
        viewModel.load()
      }
    }
  }
}

@MainActor
public enum TimelineBuilder {
  public static func make(services: AppServices, account: Account? = nil) -> TimelineView {
    let presenter = TimelinePresenter()
    let interactor = TimelineInteractor(services: services, presenter: presenter)
    let viewModel = TimelineViewModel(account: account, interactor: interactor)
    presenter.displayLogic = viewModel
    return TimelineView(viewModel: viewModel)
  }
}
