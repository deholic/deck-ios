import Foundation

public enum Platform: String, Codable, Sendable {
  case mastodon
  case misskey
}

public struct Account: Identifiable, Codable, Equatable, Sendable {
  public let id: String
  public var username: String
  public var instanceURL: URL
  public var platform: Platform
  public var accessToken: String?

  public init(
    id: String,
    username: String,
    instanceURL: URL,
    platform: Platform,
    accessToken: String? = nil
  ) {
    self.id = id
    self.username = username
    self.instanceURL = instanceURL
    self.platform = platform
    self.accessToken = accessToken
  }
}

public enum TimelineType: String, Codable, Sendable {
  case home
  case local
  case federated
}

public struct TimelineSection: Identifiable, Codable, Equatable, Sendable {
  public let id: String
  public var accountId: String?
  public var type: TimelineType
  public var title: String

  public init(id: String, accountId: String?, type: TimelineType, title: String) {
    self.id = id
    self.accountId = accountId
    self.type = type
    self.title = title
  }
}

public enum Visibility: String, Codable, Sendable {
  case `public`
  case unlisted
  case followers
  case direct
}

public struct Emoji: Codable, Equatable, Sendable {
  public let shortcode: String
  public let url: URL

  public init(shortcode: String, url: URL) {
    self.shortcode = shortcode
    self.url = url
  }
}

public struct Reaction: Codable, Equatable, Sendable {
  public let name: String
  public var count: Int
  public var me: Bool

  public init(name: String, count: Int, me: Bool) {
    self.name = name
    self.count = count
    self.me = me
  }
}

public struct Attachment: Identifiable, Codable, Equatable, Sendable {
  public let id: String
  public let url: URL
  public let previewURL: URL?

  public init(id: String, url: URL, previewURL: URL? = nil) {
    self.id = id
    self.url = url
    self.previewURL = previewURL
  }
}

public struct Status: Identifiable, Codable, Equatable, Sendable {
  public let id: String
  public var content: String
  public var author: Account
  public var createdAt: Date
  public var visibility: Visibility
  public var attachments: [Attachment]
  public var reactions: [Reaction]
  public var isSensitive: Bool
  public var isFavourite: Bool
  public var isReposted: Bool
  public var contentWarning: String?

  public init(
    id: String,
    content: String,
    author: Account,
    createdAt: Date,
    visibility: Visibility,
    attachments: [Attachment] = [],
    reactions: [Reaction] = [],
    isSensitive: Bool = false,
    isFavourite: Bool = false,
    isReposted: Bool = false,
    contentWarning: String? = nil
  ) {
    self.id = id
    self.content = content
    self.author = author
    self.createdAt = createdAt
    self.visibility = visibility
    self.attachments = attachments
    self.reactions = reactions
    self.isSensitive = isSensitive
    self.isFavourite = isFavourite
    self.isReposted = isReposted
    self.contentWarning = contentWarning
  }
}

public enum SectionSize: String, Codable, Sendable {
  case small
  case medium
  case large
}

public enum ThemeStyle: String, Codable, Sendable {
  case `default`
  case christmas
  case skyPink
  case monochrome
}

public struct AppSettings: Codable, Equatable, Sendable {
  public var showCustomEmojis: Bool
  public var showReactions: Bool
  public var showProfileImages: Bool
  public var sectionSize: SectionSize
  public var theme: ThemeStyle

  public init(
    showCustomEmojis: Bool = true,
    showReactions: Bool = true,
    showProfileImages: Bool = true,
    sectionSize: SectionSize = .medium,
    theme: ThemeStyle = .default
  ) {
    self.showCustomEmojis = showCustomEmojis
    self.showReactions = showReactions
    self.showProfileImages = showProfileImages
    self.sectionSize = sectionSize
    self.theme = theme
  }
}
