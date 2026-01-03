import Foundation
import DeckDomain

public protocol AccountAuthenticationServicing: Sendable {
  func startAuthentication(service: AccountServiceType, instance: URL) async throws -> AuthSession
  func finishAuthentication(session: AuthSession, callbackURL: URL) async throws -> Account
}

public struct AccountAuthenticationService: AccountAuthenticationServicing {
  private let client: NetworkClient
  private let callbackScheme = "deckauth"
  private let scopes = "read write follow"

  public init(client: NetworkClient) {
    self.client = client
  }

  public func startAuthentication(service: AccountServiceType, instance: URL) async throws -> AuthSession {
    switch service {
    case .mastodon:
      return try await startMastodon(instance: instance)
    case .misskey:
      return try await startMisskey(instance: instance)
    }
  }

  public func finishAuthentication(session: AuthSession, callbackURL: URL) async throws -> Account {
    switch session.data {
    case .mastodon(let mastodonSession):
      return try await finishMastodon(instance: session.instance, session: mastodonSession, callbackURL: callbackURL)
    case .misskey(let misskeySession):
      return try await finishMisskey(instance: session.instance, session: misskeySession)
    }
  }

  private func startMastodon(instance: URL) async throws -> AuthSession {
    struct AppRegistrationRequest: Encodable {
      let clientName: String
      let redirectUris: String
      let scopes: String
      let website: String

      enum CodingKeys: String, CodingKey {
        case clientName = "client_name"
        case redirectUris = "redirect_uris"
        case scopes
        case website
      }
    }

    struct AppRegistrationResponse: Decodable {
      let clientId: String
      let clientSecret: String
      let redirectUri: String

      enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case redirectUri = "redirect_uri"
      }
    }

    let redirectURI = "\(callbackScheme)://oauth-callback"
    let request = AppRegistrationRequest(
      clientName: "Deck",
      redirectUris: redirectURI,
      scopes: scopes,
      website: "https://github.com/deholic/deck"
    )

    let appURL = instance.appendingPathComponent("api/v1/apps")
    let registration: AppRegistrationResponse = try await client.send(url: appURL, method: "POST", body: request)

    var components = URLComponents(url: instance.appendingPathComponent("oauth/authorize"), resolvingAgainstBaseURL: false)
    components?.queryItems = [
      URLQueryItem(name: "client_id", value: registration.clientId),
      URLQueryItem(name: "redirect_uri", value: registration.redirectUri),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: scopes)
    ]

    guard let authURL = components?.url else {
      throw AuthenticationError.invalidInstance
    }

    let session = MastodonSession(
      clientId: registration.clientId,
      clientSecret: registration.clientSecret,
      redirectURI: registration.redirectUri
    )

    return AuthSession(
      service: .mastodon,
      instance: instance,
      authorizationURL: authURL,
      callbackScheme: callbackScheme,
      data: .mastodon(session)
    )
  }

  private func finishMastodon(instance: URL, session: MastodonSession, callbackURL: URL) async throws -> Account {
    guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value else {
      throw AuthenticationError.missingAuthorizationCode
    }

    struct TokenResponse: Decodable {
      let accessToken: String

      enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
      }
    }

    let tokenURL = instance.appendingPathComponent("oauth/token")
    let tokenResponse: TokenResponse = try await client.sendForm(
      url: tokenURL,
      body: [
        "grant_type": "authorization_code",
        "code": code,
        "client_id": session.clientId,
        "client_secret": session.clientSecret,
        "redirect_uri": session.redirectURI,
        "scope": scopes
      ]
    )

    struct VerifyCredentialsResponse: Decodable {
      let username: String
    }

    let verifyURL = instance.appendingPathComponent("api/v1/accounts/verify_credentials")
    let response: VerifyCredentialsResponse = try await client.send(
      url: verifyURL,
      method: "GET",
      headers: ["Authorization": "Bearer \(tokenResponse.accessToken)"]
    )

    return Account(
      id: UUID().uuidString,
      username: response.username,
      instanceURL: instance,
      platform: AccountServiceType.mastodon.platform,
      accessToken: tokenResponse.accessToken
    )
  }

  private func startMisskey(instance: URL) async throws -> AuthSession {
    struct AppCreateRequest: Encodable {
      let name: String
      let description: String
      let permission: [String]
      let callbackUrl: String
    }

    struct AppCreateResponse: Decodable {
      let secret: String
    }

    let callbackURL = "\(callbackScheme)://oauth-callback"
    let createURL = instance.appendingPathComponent("api/app/create")
    let appResponse: AppCreateResponse = try await client.send(
      url: createURL,
      method: "POST",
      body: AppCreateRequest(
        name: "Deck",
        description: "Deck for Misskey",
        permission: ["read:account", "read:drive", "read:notes", "write:notes"],
        callbackUrl: callbackURL
      )
    )

    struct SessionRequest: Encodable {
      let appSecret: String
    }

    struct SessionResponse: Decodable {
      let token: String
      let url: String
    }

    let sessionURL = instance.appendingPathComponent("api/auth/session/generate")
    let sessionResponse: SessionResponse = try await client.send(
      url: sessionURL,
      method: "POST",
      body: SessionRequest(appSecret: appResponse.secret)
    )

    guard let authURL = URL(string: sessionResponse.url) else {
      throw AuthenticationError.invalidInstance
    }

    let session = MisskeySession(appSecret: appResponse.secret, token: sessionResponse.token, callbackURL: callbackURL)

    return AuthSession(
      service: .misskey,
      instance: instance,
      authorizationURL: authURL,
      callbackScheme: callbackScheme,
      data: .misskey(session)
    )
  }

  private func finishMisskey(instance: URL, session: MisskeySession) async throws -> Account {
    struct UserKeyRequest: Encodable {
      let appSecret: String
      let token: String
    }

    struct UserKeyResponse: Decodable {
      let accessToken: String
      let user: UserResponse

      enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case user
      }
    }

    struct UserResponse: Decodable {
      let username: String
    }

    let userKeyURL = instance.appendingPathComponent("api/auth/session/userkey")
    let response: UserKeyResponse = try await client.send(
      url: userKeyURL,
      method: "POST",
      body: UserKeyRequest(appSecret: session.appSecret, token: session.token)
    )

    return Account(
      id: UUID().uuidString,
      username: response.user.username,
      instanceURL: instance,
      platform: AccountServiceType.misskey.platform,
      accessToken: response.accessToken
    )
  }
}
