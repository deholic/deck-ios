import SwiftUI
import DeckServices

public enum ComposeBuilder {
  public static func make(services: AppServices) -> some View {
    NavigationStack {
      ContentUnavailableView("Compose", systemImage: "square.and.pencil")
        .navigationTitle("Compose")
    }
  }
}
