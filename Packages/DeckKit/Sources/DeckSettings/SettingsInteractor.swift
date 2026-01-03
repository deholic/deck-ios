import Foundation

protocol SettingsBusinessLogic {
  func loadSettings() async
  func updateTheme(_ theme: ThemeOption) async
  func updateRefreshInterval(_ interval: Int) async
  func updateAutoplayVideos(_ isEnabled: Bool) async
  func updateHapticsEnabled(_ isEnabled: Bool) async
  func resetSettings() async
}

@MainActor
protocol SettingsPresentationLogic: AnyObject {
  func presentSettings(_ response: SettingsModels.Load.Response)
  func presentUpdatedSettings(_ response: SettingsModels.Update.Response)
  func presentError(_ message: String)
  func setLoading(_ isLoading: Bool)
}

@MainActor
protocol SettingsDisplayLogic: AnyObject {
  func displaySettings(_ viewModel: SettingsModels.Load.ViewModel)
  func displayUpdatedSettings(_ viewModel: SettingsModels.Update.ViewModel)
  func displayError(_ viewModel: SettingsModels.ErrorState.ViewModel)
  func setLoading(_ isLoading: Bool)
}

final class SettingsInteractor: SettingsBusinessLogic {
  private let presenter: SettingsPresentationLogic
  private let worker: SettingsWorker

  init(presenter: SettingsPresentationLogic, worker: SettingsWorker) {
    self.presenter = presenter
    self.worker = worker
  }

  func loadSettings() async {
    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      let settings = try await worker.loadSettings()
      await presenter.presentSettings(.init(settings: settings))
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }

  func updateTheme(_ theme: ThemeOption) async {
    await updateSettings { try await worker.updateTheme(theme) }
  }

  func updateRefreshInterval(_ interval: Int) async {
    await updateSettings { try await worker.updateRefreshInterval(interval) }
  }

  func updateAutoplayVideos(_ isEnabled: Bool) async {
    await updateSettings { try await worker.updateAutoplayVideos(isEnabled) }
  }

  func updateHapticsEnabled(_ isEnabled: Bool) async {
    await updateSettings { try await worker.updateHapticsEnabled(isEnabled) }
  }

  func resetSettings() async {
    await updateSettings { try await worker.resetSettings() }
  }

  private func updateSettings(_ work: @escaping () async throws -> SettingsModels.Settings) async {
    await presenter.setLoading(true)
    defer { Task { await presenter.setLoading(false) } }
    do {
      let settings = try await work()
      await presenter.presentUpdatedSettings(.init(settings: settings))
    } catch {
      await presenter.presentError(error.localizedDescription)
    }
  }
}
