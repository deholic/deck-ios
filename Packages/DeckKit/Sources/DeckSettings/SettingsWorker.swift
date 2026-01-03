import Foundation

final class SettingsWorker {
  private let userDefaults: UserDefaults

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }

  func loadSettings() async throws -> SettingsModels.Settings {
    SettingsModels.Settings(
      theme: loadTheme(),
      refreshInterval: loadRefreshInterval(),
      autoplayVideos: userDefaults.object(forKey: Keys.autoplayVideos) as? Bool ?? SettingsModels.Settings.default.autoplayVideos,
      hapticsEnabled: userDefaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? SettingsModels.Settings.default.hapticsEnabled
    )
  }

  func updateTheme(_ theme: ThemeOption) async throws -> SettingsModels.Settings {
    userDefaults.set(theme.rawValue, forKey: Keys.theme)
    return try await loadSettings()
  }

  func updateRefreshInterval(_ interval: Int) async throws -> SettingsModels.Settings {
    userDefaults.set(interval, forKey: Keys.refreshInterval)
    return try await loadSettings()
  }

  func updateAutoplayVideos(_ isEnabled: Bool) async throws -> SettingsModels.Settings {
    userDefaults.set(isEnabled, forKey: Keys.autoplayVideos)
    return try await loadSettings()
  }

  func updateHapticsEnabled(_ isEnabled: Bool) async throws -> SettingsModels.Settings {
    userDefaults.set(isEnabled, forKey: Keys.hapticsEnabled)
    return try await loadSettings()
  }

  func resetSettings() async throws -> SettingsModels.Settings {
    userDefaults.removeObject(forKey: Keys.theme)
    userDefaults.removeObject(forKey: Keys.refreshInterval)
    userDefaults.removeObject(forKey: Keys.autoplayVideos)
    userDefaults.removeObject(forKey: Keys.hapticsEnabled)
    return SettingsModels.Settings.default
  }

  private func loadTheme() -> ThemeOption {
    guard let raw = userDefaults.string(forKey: Keys.theme),
          let theme = ThemeOption(rawValue: raw) else {
      return SettingsModels.Settings.default.theme
    }
    return theme
  }

  private func loadRefreshInterval() -> Int {
    let stored = userDefaults.object(forKey: Keys.refreshInterval) as? Int
    return stored ?? SettingsModels.Settings.default.refreshInterval
  }

  private enum Keys {
    static let theme = "settings.theme"
    static let refreshInterval = "settings.refreshInterval"
    static let autoplayVideos = "settings.autoplayVideos"
    static let hapticsEnabled = "settings.hapticsEnabled"
  }
}
