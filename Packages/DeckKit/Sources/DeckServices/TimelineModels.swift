import Foundation

public struct TimelineAuthor: Sendable, Equatable {
  public let displayName: String
  public let handle: String
  public let avatarURL: URL?

  public init(displayName: String, handle: String, avatarURL: URL?) {
    self.displayName = displayName
    self.handle = handle
    self.avatarURL = avatarURL
  }
}

public struct TimelineMetrics: Sendable, Equatable {
  public let replies: Int
  public let boosts: Int
  public let favorites: Int

  public init(replies: Int, boosts: Int, favorites: Int) {
    self.replies = replies
    self.boosts = boosts
    self.favorites = favorites
  }
}

public struct TimelineReaction: Sendable, Equatable, Identifiable {
  public let id: String
  public let name: String
  public let count: Int
  public let isMine: Bool

  public init(name: String, count: Int, isMine: Bool) {
    self.id = name
    self.name = name
    self.count = count
    self.isMine = isMine
  }
}

public struct TimelineActionState: Sendable, Equatable {
  public let isBoosted: Bool
  public let isFavorited: Bool
  public let isBookmarked: Bool

  public init(isBoosted: Bool, isFavorited: Bool, isBookmarked: Bool) {
    self.isBoosted = isBoosted
    self.isFavorited = isFavorited
    self.isBookmarked = isBookmarked
  }
}

public struct TimelinePost: Identifiable, Sendable, Equatable {
  public let id: String
  public let service: AccountServiceType
  public let author: TimelineAuthor
  public let content: String
  public let createdAt: Date
  public let url: URL?
  public let boostedBy: String?
  public let metrics: TimelineMetrics
  public let actions: TimelineActionState
  public let reactions: [TimelineReaction]

  public init(
    id: String,
    service: AccountServiceType,
    author: TimelineAuthor,
    content: String,
    createdAt: Date,
    url: URL?,
    boostedBy: String?,
    metrics: TimelineMetrics,
    actions: TimelineActionState,
    reactions: [TimelineReaction]
  ) {
    self.id = id
    self.service = service
    self.author = author
    self.content = content
    self.createdAt = createdAt
    self.url = url
    self.boostedBy = boostedBy
    self.metrics = metrics
    self.actions = actions
    self.reactions = reactions
  }
}
