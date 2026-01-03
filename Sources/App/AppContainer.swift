import Foundation
import DeckServices

final class AppContainer: ObservableObject {
  let services: AppServices

  init(services: AppServices = DefaultAppServices.make()) {
    self.services = services
  }
}
