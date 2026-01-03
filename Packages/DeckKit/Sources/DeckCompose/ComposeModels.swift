import DeckDomain

public enum ComposeModels {
  public enum Post {
    public struct Request: Sendable {
      public let account: Account?
      public let content: String
      public let visibility: Visibility
      public let contentWarning: String?

      public init(account: Account?, content: String, visibility: Visibility, contentWarning: String?) {
        self.account = account
        self.content = content
        self.visibility = visibility
        self.contentWarning = contentWarning
      }
    }

    public struct Response: Sendable {
      public let status: Status?
      public init(status: Status?) {
        self.status = status
      }
    }

    public struct ViewModel: Sendable {
      public let didPost: Bool
      public init(didPost: Bool) {
        self.didPost = didPost
      }
    }
  }
}
