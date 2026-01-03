import Foundation
import DeckDomain

public enum AccountServiceType: String, Codable, CaseIterable, Identifiable, Sendable {
  case mastodon
  case misskey

  public var id: String { rawValue }

  public var displayName: String {
    switch self {
    case .mastodon:
      return "Mastodon"
    case .misskey:
      return "Misskey"
    }
  }
}

public typealias Account = DeckDomain.Account

public enum AuthenticationError: Error, LocalizedError {
  case invalidInstance
  case invalidCallbackURL
  case missingAuthorizationCode
  case unexpectedResponse

  public var errorDescription: String? {
    switch self {
    case .invalidInstance:
      return "The instance URL is invalid."
    case .invalidCallbackURL:
      return "Authentication could not be completed."
    case .missingAuthorizationCode:
      return "The authorization code was not returned."
    case .unexpectedResponse:
      return "The server returned an unexpected response."
    }
  }
}

public struct AuthSession: Sendable, Equatable {
  public let service: AccountServiceType
  public let instance: URL
  public let authorizationURL: URL
  public let callbackScheme: String
  public let data: AuthSessionData

  public init(service: AccountServiceType, instance: URL, authorizationURL: URL, callbackScheme: String, data: AuthSessionData) {
    self.service = service
    self.instance = instance
    self.authorizationURL = authorizationURL
    self.callbackScheme = callbackScheme
    self.data = data
  }
}

public extension AccountServiceType {
  var platform: Platform {
    switch self {
    case .mastodon:
      return .mastodon
    case .misskey:
      return .misskey
    }
  }
}

public enum AuthSessionData: Sendable, Equatable {
  case mastodon(MastodonSession)
  case misskey(MisskeySession)
}

public struct MastodonSession: Sendable, Equatable {
  public let clientId: String
  public let clientSecret: String
  public let redirectURI: String

  public init(clientId: String, clientSecret: String, redirectURI: String) {
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.redirectURI = redirectURI
  }
}

public struct MisskeySession: Sendable, Equatable {
  public let appSecret: String
  public let token: String
  public let callbackURL: String

  public init(appSecret: String, token: String, callbackURL: String) {
    self.appSecret = appSecret
    self.token = token
    self.callbackURL = callbackURL
  }
}
