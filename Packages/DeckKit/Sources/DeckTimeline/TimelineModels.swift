import DeckDomain

public enum TimelineModels {
  public enum Load {
    public struct Request: Sendable {
      public let account: Account?
      public init(account: Account?) {
        self.account = account
      }
    }
    public struct Response: Sendable {
      public let statuses: [Status]
      public init(statuses: [Status]) {
        self.statuses = statuses
      }
    }
    public struct ViewModel: Sendable {
      public let statuses: [Status]
      public init(statuses: [Status]) {
        self.statuses = statuses
      }
    }
  }
}
