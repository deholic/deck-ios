import SwiftUI
import DeckServices

public enum TimelineBuilder {
  public static func make(services: AppServices) -> some View {
    NavigationStack {
      ContentUnavailableView("Timeline", systemImage: "list.bullet.rectangle")
        .navigationTitle("Timeline")
    }
  }
}
