import Foundation

public protocol AppServices {
  var accountStore: AccountStore { get }
  var authenticationService: AccountAuthenticationServicing { get }
}

public struct DefaultAppServices: AppServices {
  public let accountStore: AccountStore
  public let authenticationService: AccountAuthenticationServicing

  public init(accountStore: AccountStore, authenticationService: AccountAuthenticationServicing) {
    self.accountStore = accountStore
    self.authenticationService = authenticationService
  }

  public static func make() -> DefaultAppServices {
    let storage = UserDefaultsAccountStorage(userDefaults: .standard)
    let accountStore = AccountStore(storage: storage)
    let client = NetworkClient(urlSession: .shared)
    let authenticationService = AccountAuthenticationService(client: client)
    return DefaultAppServices(accountStore: accountStore, authenticationService: authenticationService)
  }
}
