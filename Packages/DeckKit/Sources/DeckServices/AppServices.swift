import Foundation

public protocol AppServices {
  var accountStore: AccountStore { get }
  var authenticationService: AccountAuthenticationServicing { get }
  var postingService: PostingServicing { get }
}

public struct DefaultAppServices: AppServices {
  public let accountStore: AccountStore
  public let authenticationService: AccountAuthenticationServicing
  public let postingService: PostingServicing

  public init(accountStore: AccountStore, authenticationService: AccountAuthenticationServicing, postingService: PostingServicing) {
    self.accountStore = accountStore
    self.authenticationService = authenticationService
    self.postingService = postingService
  }

  public static func make() -> DefaultAppServices {
    let storage = UserDefaultsAccountStorage(userDefaults: .standard)
    let accountStore = AccountStore(storage: storage)
    let client = NetworkClient(urlSession: .shared)
    let authenticationService = AccountAuthenticationService(client: client)
    let postingService = PostingService(client: client)
    return DefaultAppServices(accountStore: accountStore, authenticationService: authenticationService, postingService: postingService)
  }
}
