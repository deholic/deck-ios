import Foundation
import DeckDomain

public protocol APIService: Sendable {
  func fetchHomeTimeline(account: Account) async throws -> [Status]
  func fetchMoreHomeTimeline(account: Account, from statusId: String?) async throws -> [Status]
  func postStatus(
    account: Account,
    content: String,
    visibility: Visibility,
    attachments: [Attachment],
    contentWarning: String?
  ) async throws -> Status
  func deleteStatus(account: Account, statusId: String) async throws
  func toggleFavourite(account: Account, statusId: String, isFavourite: Bool) async throws -> Status
  func toggleRepost(account: Account, statusId: String, isReposted: Bool) async throws -> Status
  func uploadMedia(account: Account, data: Data, mimeType: String) async throws -> Attachment
  func fetchCustomEmojis(account: Account) async throws -> [Emoji]
}

public protocol StreamingService: Sendable {
  func streamHomeTimeline(
    account: Account,
    onStatus: @escaping @Sendable (Status) -> Void
  ) -> StreamToken
}

public protocol StorageService: Sendable {
  func loadAccounts() async -> [Account]
  func saveAccounts(_ accounts: [Account]) async
  func loadSettings() async -> AppSettings
  func saveSettings(_ settings: AppSettings) async
}

public final class StreamToken: @unchecked Sendable {
  private let cancelHandler: () -> Void

  public init(cancel: @escaping () -> Void) {
    self.cancelHandler = cancel
  }

  public func cancel() {
    cancelHandler()
  }
}

public struct AppServices: Sendable {
  public let api: APIService
  public let streaming: StreamingService
  public let storage: StorageService
  public let accountStore: AccountStore
  public let authenticationService: AccountAuthenticationServicing

  public init(
    api: APIService,
    streaming: StreamingService,
    storage: StorageService,
    accountStore: AccountStore,
    authenticationService: AccountAuthenticationServicing
  ) {
    self.api = api
    self.streaming = streaming
    self.storage = storage
    self.accountStore = accountStore
    self.authenticationService = authenticationService
  }
}

public struct DefaultAppServices {
  public static func make() -> AppServices {
    let storage = InMemoryStorageService()
    let accountStorage = UserDefaultsAccountStorage(userDefaults: .standard)
    let accountStore = AccountStore(storage: accountStorage)
    let client = NetworkClient(urlSession: .shared)
    let authenticationService = AccountAuthenticationService(client: client)
    return AppServices(
      api: MockAPIService(),
      streaming: MockStreamingService(),
      storage: storage,
      accountStore: accountStore,
      authenticationService: authenticationService
    )
  }
}

actor InMemoryStorageService: StorageService {
  private var accounts: [Account] = []
  private var settings = AppSettings()

  func loadAccounts() async -> [Account] {
    accounts
  }

  func saveAccounts(_ accounts: [Account]) async {
    self.accounts = accounts
  }

  func loadSettings() async -> AppSettings {
    settings
  }

  func saveSettings(_ settings: AppSettings) async {
    self.settings = settings
  }
}

struct MockAPIService: APIService {
  func fetchHomeTimeline(account: Account) async throws -> [Status] {
    []
  }

  func fetchMoreHomeTimeline(account: Account, from statusId: String?) async throws -> [Status] {
    []
  }

  func postStatus(
    account: Account,
    content: String,
    visibility: Visibility,
    attachments: [Attachment],
    contentWarning: String?
  ) async throws -> Status {
    Status(
      id: UUID().uuidString,
      content: content,
      author: account,
      createdAt: Date(),
      visibility: visibility
    )
  }

  func deleteStatus(account: Account, statusId: String) async throws {
  }

  func toggleFavourite(account: Account, statusId: String, isFavourite: Bool) async throws -> Status {
    Status(
      id: statusId,
      content: "",
      author: account,
      createdAt: Date(),
      visibility: .public,
      isFavourite: isFavourite
    )
  }

  func toggleRepost(account: Account, statusId: String, isReposted: Bool) async throws -> Status {
    Status(
      id: statusId,
      content: "",
      author: account,
      createdAt: Date(),
      visibility: .public,
      isReposted: isReposted
    )
  }

  func uploadMedia(account: Account, data: Data, mimeType: String) async throws -> Attachment {
    Attachment(id: UUID().uuidString, url: URL(fileURLWithPath: "/dev/null"))
  }

  func fetchCustomEmojis(account: Account) async throws -> [Emoji] {
    []
  }
}

struct MockStreamingService: StreamingService {
  func streamHomeTimeline(
    account: Account,
    onStatus: @escaping @Sendable (Status) -> Void
  ) -> StreamToken {
    StreamToken(cancel: {})
  }
}
