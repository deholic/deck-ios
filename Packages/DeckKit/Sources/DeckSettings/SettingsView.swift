import SwiftUI
import DeckDomain
import DeckServices

@MainActor
public protocol SettingsDisplayLogic: AnyObject {
  func displaySettings(_ viewModel: SettingsModels.Load.ViewModel)
}

@MainActor
public final class SettingsViewModel: ObservableObject, SettingsDisplayLogic {
  @Published public var settings = AppSettings()
  private let interactor: SettingsBusinessLogic

  public init(interactor: SettingsBusinessLogic) {
    self.interactor = interactor
  }

  public func load() {
    Task {
      await interactor.loadSettings(.init())
    }
  }

  public func save() {
    Task {
      await interactor.saveSettings(.init(settings: settings))
    }
  }

  public func displaySettings(_ viewModel: SettingsModels.Load.ViewModel) {
    settings = viewModel.settings
  }
}

public struct SettingsView: View {
  @StateObject private var viewModel: SettingsViewModel

  public init(viewModel: SettingsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  public var body: some View {
    NavigationStack {
      Form {
        Section("Display") {
          Toggle("Custom emojis", isOn: Binding(
            get: { viewModel.settings.showCustomEmojis },
            set: { viewModel.settings.showCustomEmojis = $0; viewModel.save() }
          ))
          Toggle("Reactions", isOn: Binding(
            get: { viewModel.settings.showReactions },
            set: { viewModel.settings.showReactions = $0; viewModel.save() }
          ))
          Toggle("Profile images", isOn: Binding(
            get: { viewModel.settings.showProfileImages },
            set: { viewModel.settings.showProfileImages = $0; viewModel.save() }
          ))
        }

        Section("Section size") {
          Picker("Size", selection: Binding(
            get: { viewModel.settings.sectionSize },
            set: { viewModel.settings.sectionSize = $0; viewModel.save() }
          )) {
            Text("Small").tag(SectionSize.small)
            Text("Medium").tag(SectionSize.medium)
            Text("Large").tag(SectionSize.large)
          }
        }

        Section("Theme") {
          Picker("Theme", selection: Binding(
            get: { viewModel.settings.theme },
            set: { viewModel.settings.theme = $0; viewModel.save() }
          )) {
            Text("Default").tag(ThemeStyle.default)
            Text("Christmas").tag(ThemeStyle.christmas)
            Text("Sky Pink").tag(ThemeStyle.skyPink)
            Text("Monochrome").tag(ThemeStyle.monochrome)
          }
        }
      }
      .navigationTitle("Settings")
      .onAppear {
        viewModel.load()
      }
    }
  }
}

@MainActor
public enum SettingsBuilder {
  public static func make(services: AppServices) -> SettingsView {
    let presenter = SettingsPresenter()
    let interactor = SettingsInteractor(services: services, presenter: presenter)
    let viewModel = SettingsViewModel(interactor: interactor)
    presenter.displayLogic = viewModel
    return SettingsView(viewModel: viewModel)
  }
}
