import Foundation
import DeckServices

enum TimelineModels {
  enum Load {
    struct Response {
      let accounts: [Account]
      let posts: [TimelinePost]
      let selectedAccountId: UUID?
      let isStreaming: Bool
    }

    struct ViewModel {
      let accounts: [TimelineAccountViewModel]
      let posts: [TimelinePostViewModel]
      let selectedAccountId: UUID?
      let isStreaming: Bool
    }
  }

  enum ErrorState {
    struct ViewModel {
      let message: String
    }
  }

  enum Reply {
    struct Request {
      let postId: String
      let text: String
    }
  }
}

struct TimelineAccountViewModel: Identifiable, Equatable {
  let id: UUID
  let title: String
  let subtitle: String
}

struct TimelinePostViewModel: Identifiable, Equatable {
  let id: String
  let service: AccountServiceType
  let authorName: String
  let authorHandle: String
  let avatarURL: URL?
  let content: String
  let createdAt: String
  let boostedBy: String?
  let replyCount: Int
  let boostCount: Int
  let favoriteCount: Int
  let reactions: [TimelineReactionViewModel]
  let isBoosted: Bool
  let isFavorited: Bool
  let isBookmarked: Bool
  let canReact: Bool
  let url: URL?
}

struct TimelineReactionViewModel: Identifiable, Equatable {
  let id: String
  let name: String
  let count: Int
  let isMine: Bool
}
