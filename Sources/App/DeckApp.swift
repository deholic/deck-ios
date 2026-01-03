import SwiftUI

@main
struct DeckApp: App {
  @StateObject private var container = AppContainer()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(container)
    }
  }
}
