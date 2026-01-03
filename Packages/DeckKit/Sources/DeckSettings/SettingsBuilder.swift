import SwiftUI
import DeckServices

public enum SettingsBuilder {
  public static func make(services: AppServices) -> some View {
    NavigationStack {
      ContentUnavailableView("Settings", systemImage: "gearshape")
        .navigationTitle("Settings")
    }
  }
}
