import Foundation

public enum PostingVisibility: String, CaseIterable, Identifiable, Sendable {
  case `public`
  case unlisted
  case followersOnly
  case direct

  public var id: String { rawValue }

  public var displayName: String {
    switch self {
    case .public:
      return "Public"
    case .unlisted:
      return "Unlisted"
    case .followersOnly:
      return "Followers Only"
    case .direct:
      return "Direct"
    }
  }

  var mastodonValue: String {
    switch self {
    case .public:
      return "public"
    case .unlisted:
      return "unlisted"
    case .followersOnly:
      return "private"
    case .direct:
      return "direct"
    }
  }
}

public protocol PostingServicing: Sendable {
  func createPost(account: Account, text: String, visibility: PostingVisibility) async throws
}

public struct PostingService: PostingServicing {
  private let client: NetworkClient

  public init(client: NetworkClient) {
    self.client = client
  }

  public func createPost(account: Account, text: String, visibility: PostingVisibility) async throws {
    switch account.service {
    case .mastodon:
      try await createMastodonPost(account: account, text: text, visibility: visibility)
    case .misskey:
      try await createMisskeyPost(account: account, text: text, visibility: visibility)
    }
  }

  private func createMastodonPost(account: Account, text: String, visibility: PostingVisibility) async throws {
    let url = account.instance.appendingPathComponent("api/v1/statuses")
    let request = MastodonStatusRequest(status: text, visibility: visibility.mastodonValue)
    try await client.sendEmpty(url: url, method: "POST", body: request, headers: [
      "Authorization": "Bearer \(account.accessToken)"
    ])
  }

  private func createMisskeyPost(account: Account, text: String, visibility: PostingVisibility) async throws {
    let url = account.instance.appendingPathComponent("api/notes/create")
    let request = MisskeyNoteRequest(i: account.accessToken, text: text, visibility: visibility.mastodonValue)
    try await client.sendEmpty(url: url, method: "POST", body: request)
  }
}

private struct MastodonStatusRequest: Encodable {
  let status: String
  let visibility: String
}

private struct MisskeyNoteRequest: Encodable {
  let i: String
  let text: String
  let visibility: String
}
