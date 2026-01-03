import Foundation

enum SettingsModels {
  enum Load {
    struct Request {}
    struct Response {
      let settings: Settings
    }
    struct ViewModel {
      let settings: SettingsViewModel
    }
  }

  enum Update {
    struct Response {
      let settings: Settings
    }
    struct ViewModel {
      let settings: SettingsViewModel
    }
  }

  enum ErrorState {
    struct ViewModel {
      let message: String
    }
  }

  struct Settings: Equatable {
    let theme: ThemeOption
    let refreshInterval: Int
    let autoplayVideos: Bool
    let hapticsEnabled: Bool
  }

  struct SettingsViewModel: Equatable {
    let theme: ThemeOption
    let refreshInterval: Int
    let autoplayVideos: Bool
    let hapticsEnabled: Bool
  }
}

extension SettingsModels.Settings {
  static let `default` = SettingsModels.Settings(
    theme: .system,
    refreshInterval: 15,
    autoplayVideos: true,
    hapticsEnabled: true
  )
}

extension SettingsModels.SettingsViewModel {
  init(settings: SettingsModels.Settings) {
    self.init(
      theme: settings.theme,
      refreshInterval: settings.refreshInterval,
      autoplayVideos: settings.autoplayVideos,
      hapticsEnabled: settings.hapticsEnabled
    )
  }
}

enum ThemeOption: String, CaseIterable, Identifiable, Codable {
  case system
  case light
  case dark

  var id: String { rawValue }

  var title: String {
    switch self {
    case .system:
      return "System"
    case .light:
      return "Light"
    case .dark:
      return "Dark"
    }
  }
}
