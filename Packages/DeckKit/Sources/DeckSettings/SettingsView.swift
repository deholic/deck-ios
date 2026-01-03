import SwiftUI

struct SettingsView: View {
  @StateObject private var state: SettingsViewState
  private let interactor: SettingsBusinessLogic

  init(state: SettingsViewState, interactor: SettingsBusinessLogic) {
    _state = StateObject(wrappedValue: state)
    self.interactor = interactor
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Appearance") {
          Picker("Theme", selection: $state.theme) {
            ForEach(ThemeOption.allCases) { option in
              Text(option.title).tag(option)
            }
          }
        }

        Section("Timeline") {
          Stepper(value: $state.refreshInterval, in: 5...60, step: 5) {
            Text("Refresh every \(state.refreshInterval) min")
          }
          Toggle("Autoplay videos", isOn: $state.autoplayVideos)
        }

        Section("Feedback") {
          Toggle("Haptics", isOn: $state.hapticsEnabled)
        }

        Section {
          Button(role: .destructive) {
            Task { await interactor.resetSettings() }
          } label: {
            Text("Reset to Defaults")
          }
        }
      }
      .navigationTitle("Settings")
      .overlay {
        if state.isLoading {
          ProgressView()
        }
      }
      .task {
        await interactor.loadSettings()
      }
      .onChange(of: state.theme) { _, newValue in
        guard state.isReady else { return }
        Task { await interactor.updateTheme(newValue) }
      }
      .onChange(of: state.refreshInterval) { _, newValue in
        guard state.isReady else { return }
        Task { await interactor.updateRefreshInterval(newValue) }
      }
      .onChange(of: state.autoplayVideos) { _, newValue in
        guard state.isReady else { return }
        Task { await interactor.updateAutoplayVideos(newValue) }
      }
      .onChange(of: state.hapticsEnabled) { _, newValue in
        guard state.isReady else { return }
        Task { await interactor.updateHapticsEnabled(newValue) }
      }
      .alert("Error", isPresented: Binding(
        get: { state.errorMessage != nil },
        set: { _ in state.errorMessage = nil }
      )) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(state.errorMessage ?? "Unknown error")
      }
    }
  }
}
