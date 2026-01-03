import SwiftUI
import DeckAccounts
import DeckCompose
import DeckTimeline
import DeckSettings
import DeckServices

struct RootView: View {
  @EnvironmentObject private var container: AppContainer

  var body: some View {
    TabView {
      TimelineBuilder.make(services: container.services)
        .tabItem { Label("Timeline", systemImage: "list.bullet.rectangle") }

      ComposeBuilder.make(services: container.services)
        .tabItem { Label("Compose", systemImage: "square.and.pencil") }

      AccountsBuilder.make(services: container.services)
        .tabItem { Label("Accounts", systemImage: "person.crop.circle") }

      SettingsBuilder.make(services: container.services)
        .tabItem { Label("Settings", systemImage: "gearshape") }
    }
  }
}
