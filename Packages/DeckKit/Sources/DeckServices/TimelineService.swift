import Foundation

public protocol TimelineServicing: Sendable {
  func fetchTimeline(account: Account, sinceId: String?) async throws -> [TimelinePost]
  func toggleFavorite(account: Account, postId: String, isFavorited: Bool) async throws
  func toggleBoost(account: Account, postId: String, isBoosted: Bool) async throws
  func toggleBookmark(account: Account, postId: String, isBookmarked: Bool) async throws
  func setReaction(account: Account, postId: String, reaction: String?) async throws
  func reply(account: Account, postId: String, text: String) async throws
}

public struct TimelineService: TimelineServicing {
  private let client: NetworkClient
  private let mastodonDateParser = ISO8601DateParser()

  public init(client: NetworkClient) {
    self.client = client
  }

  public func fetchTimeline(account: Account, sinceId: String?) async throws -> [TimelinePost] {
    switch account.service {
    case .mastodon:
      return try await fetchMastodonTimeline(account: account, sinceId: sinceId)
    case .misskey:
      return try await fetchMisskeyTimeline(account: account, sinceId: sinceId)
    }
  }

  public func toggleFavorite(account: Account, postId: String, isFavorited: Bool) async throws {
    switch account.service {
    case .mastodon:
      let action = isFavorited ? "unfavourite" : "favourite"
      let url = account.instance.appendingPathComponent("api/v1/statuses/\(postId)/\(action)")
      try await client.sendEmpty(url: url, method: "POST", headers: ["Authorization": "Bearer \(account.accessToken)"])
    case .misskey:
      let endpoint = isFavorited ? "api/notes/favorites/delete" : "api/notes/favorites/create"
      let url = account.instance.appendingPathComponent(endpoint)
      let request = MisskeyNoteTargetRequest(i: account.accessToken, noteId: postId)
      try await client.sendEmpty(url: url, method: "POST", body: request)
    }
  }

  public func toggleBoost(account: Account, postId: String, isBoosted: Bool) async throws {
    switch account.service {
    case .mastodon:
      let action = isBoosted ? "unreblog" : "reblog"
      let url = account.instance.appendingPathComponent("api/v1/statuses/\(postId)/\(action)")
      try await client.sendEmpty(url: url, method: "POST", headers: ["Authorization": "Bearer \(account.accessToken)"])
    case .misskey:
      if isBoosted { return }
      let url = account.instance.appendingPathComponent("api/notes/create")
      let request = MisskeyRenoteRequest(i: account.accessToken, renoteId: postId)
      try await client.sendEmpty(url: url, method: "POST", body: request)
    }
  }

  public func toggleBookmark(account: Account, postId: String, isBookmarked: Bool) async throws {
    switch account.service {
    case .mastodon:
      let action = isBookmarked ? "unbookmark" : "bookmark"
      let url = account.instance.appendingPathComponent("api/v1/statuses/\(postId)/\(action)")
      try await client.sendEmpty(url: url, method: "POST", headers: ["Authorization": "Bearer \(account.accessToken)"])
    case .misskey:
      return
    }
  }

  public func setReaction(account: Account, postId: String, reaction: String?) async throws {
    switch account.service {
    case .mastodon:
      return
    case .misskey:
      let endpoint = reaction == nil ? "api/notes/reactions/delete" : "api/notes/reactions/create"
      let url = account.instance.appendingPathComponent(endpoint)
      if let reaction {
        let request = MisskeyReactionRequest(i: account.accessToken, noteId: postId, reaction: reaction)
        try await client.sendEmpty(url: url, method: "POST", body: request)
      } else {
        let request = MisskeyNoteTargetRequest(i: account.accessToken, noteId: postId)
        try await client.sendEmpty(url: url, method: "POST", body: request)
      }
    }
  }

  public func reply(account: Account, postId: String, text: String) async throws {
    switch account.service {
    case .mastodon:
      let url = account.instance.appendingPathComponent("api/v1/statuses")
      let request = MastodonReplyRequest(status: text, inReplyToId: postId)
      try await client.sendEmpty(url: url, method: "POST", body: request, headers: ["Authorization": "Bearer \(account.accessToken)"])
    case .misskey:
      let url = account.instance.appendingPathComponent("api/notes/create")
      let request = MisskeyReplyRequest(i: account.accessToken, text: text, replyId: postId)
      try await client.sendEmpty(url: url, method: "POST", body: request)
    }
  }

  private func fetchMastodonTimeline(account: Account, sinceId: String?) async throws -> [TimelinePost] {
    var components = URLComponents(url: account.instance.appendingPathComponent("api/v1/timelines/home"), resolvingAgainstBaseURL: false)
    var items = [URLQueryItem(name: "limit", value: "30")]
    if let sinceId {
      items.append(URLQueryItem(name: "since_id", value: sinceId))
    }
    components?.queryItems = items
    guard let url = components?.url else { return [] }
    let statuses: [MastodonStatus] = try await client.send(url: url, method: "GET", headers: ["Authorization": "Bearer \(account.accessToken)"])
    return statuses.compactMap { status in
      let (sourceStatus, boostedBy) = status.reblog.map { ($0, status.account.displayNameOrHandle) } ?? (status, nil)
      guard let createdAt = mastodonDateParser.parse(sourceStatus.createdAt) else { return nil }
      let author = TimelineAuthor(displayName: sourceStatus.account.displayNameOrHandle, handle: "@\(sourceStatus.account.acct)", avatarURL: sourceStatus.account.avatar)
      let metrics = TimelineMetrics(replies: sourceStatus.repliesCount, boosts: sourceStatus.reblogsCount, favorites: sourceStatus.favouritesCount)
      let actions = TimelineActionState(isBoosted: sourceStatus.reblogged ?? false, isFavorited: sourceStatus.favourited ?? false, isBookmarked: sourceStatus.bookmarked ?? false)
      return TimelinePost(
        id: sourceStatus.id,
        service: account.service,
        author: author,
        content: sourceStatus.content.strippingHTML(),
        createdAt: createdAt,
        url: sourceStatus.url,
        boostedBy: boostedBy,
        metrics: metrics,
        actions: actions,
        reactions: []
      )
    }
  }

  private func fetchMisskeyTimeline(account: Account, sinceId: String?) async throws -> [TimelinePost] {
    let url = account.instance.appendingPathComponent("api/notes/timeline")
    let request = MisskeyTimelineRequest(i: account.accessToken, limit: 30, sinceId: sinceId)
    let notes: [MisskeyNote] = try await client.send(url: url, method: "POST", body: request)
    return notes.compactMap { note in
      let (sourceNote, boostedBy) = note.renote.map { ($0, note.user.displayNameOrHandle) } ?? (note, nil)
      guard let createdAt = mastodonDateParser.parse(sourceNote.createdAt) else { return nil }
      let author = TimelineAuthor(displayName: sourceNote.user.displayNameOrHandle, handle: sourceNote.user.handle, avatarURL: sourceNote.user.avatarUrl)
      let metrics = TimelineMetrics(replies: sourceNote.repliesCount ?? 0, boosts: sourceNote.renoteCount ?? 0, favorites: (sourceNote.reactionCounts?[":heart:"] ?? 0))
      let actions = TimelineActionState(isBoosted: false, isFavorited: sourceNote.isFavorited ?? false, isBookmarked: false)
      let reactions = (sourceNote.reactionCounts ?? [:]).map { key, value in
        TimelineReaction(name: key, count: value, isMine: sourceNote.myReaction == key)
      }.sorted { $0.name < $1.name }
      let url = sourceNote.url ?? account.instance.appendingPathComponent("notes/\(sourceNote.id)")
      return TimelinePost(
        id: sourceNote.id,
        service: account.service,
        author: author,
        content: sourceNote.text ?? "",
        createdAt: createdAt,
        url: url,
        boostedBy: boostedBy,
        metrics: metrics,
        actions: actions,
        reactions: reactions
      )
    }
  }
}

private struct MastodonStatus: Decodable {
  let id: String
  let content: String
  let createdAt: String
  let url: URL?
  let favouritesCount: Int
  let reblogsCount: Int
  let repliesCount: Int
  let favourited: Bool?
  let reblogged: Bool?
  let bookmarked: Bool?
  let account: MastodonAccount
  let reblog: MastodonStatus?

  private enum CodingKeys: String, CodingKey {
    case id
    case content
    case createdAt = "created_at"
    case url
    case favouritesCount = "favourites_count"
    case reblogsCount = "reblogs_count"
    case repliesCount = "replies_count"
    case favourited
    case reblogged
    case bookmarked
    case account
    case reblog
  }
}

private struct MastodonAccount: Decodable {
  let displayName: String
  let acct: String
  let avatar: URL?

  private enum CodingKeys: String, CodingKey {
    case displayName = "display_name"
    case acct
    case avatar
  }

  var displayNameOrHandle: String {
    displayName.isEmpty ? acct : displayName
  }
}

private struct MisskeyNote: Decodable {
  let id: String
  let text: String?
  let createdAt: String
  let repliesCount: Int?
  let renoteCount: Int?
  let reactionCounts: [String: Int]?
  let myReaction: String?
  let isFavorited: Bool?
  let user: MisskeyUser
  let renote: MisskeyNote?
  let url: URL?

  private enum CodingKeys: String, CodingKey {
    case id
    case text
    case createdAt
    case repliesCount
    case renoteCount
    case reactionCounts
    case myReaction
    case isFavorited
    case user
    case renote
    case url
  }
}

private struct MisskeyUser: Decodable {
  let name: String?
  let username: String
  let host: String?
  let avatarUrl: URL?

  var displayNameOrHandle: String {
    if let name, !name.isEmpty { return name }
    return handle
  }

  var handle: String {
    if let host, !host.isEmpty {
      return "@\(username)@\(host)"
    }
    return "@\(username)"
  }
}

private struct MastodonReplyRequest: Encodable {
  let status: String
  let inReplyToId: String

  private enum CodingKeys: String, CodingKey {
    case status
    case inReplyToId = "in_reply_to_id"
  }
}

private struct MisskeyTimelineRequest: Encodable {
  let i: String
  let limit: Int
  let sinceId: String?
}

private struct MisskeyNoteTargetRequest: Encodable {
  let i: String
  let noteId: String
}

private struct MisskeyReactionRequest: Encodable {
  let i: String
  let noteId: String
  let reaction: String
}

private struct MisskeyRenoteRequest: Encodable {
  let i: String
  let renoteId: String
}

private struct MisskeyReplyRequest: Encodable {
  let i: String
  let text: String
  let replyId: String
}

private struct ISO8601DateParser {
  private let withFractional = ISO8601DateFormatter()
  private let withoutFractional = ISO8601DateFormatter()

  init() {
    withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    withoutFractional.formatOptions = [.withInternetDateTime]
  }

  func parse(_ value: String) -> Date? {
    if let date = withFractional.date(from: value) { return date }
    return withoutFractional.date(from: value)
  }
}

private extension String {
  func strippingHTML() -> String {
    guard let data = data(using: .utf8) else { return self }
    if let attributed = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
      return attributed.string
    }
    return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
  }
}
