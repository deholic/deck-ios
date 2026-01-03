import DeckDomain

public enum SettingsModels {
  public enum Load {
    public struct Request: Sendable {}
    public struct Response: Sendable {
      public let settings: AppSettings
      public init(settings: AppSettings) {
        self.settings = settings
      }
    }
    public struct ViewModel: Sendable {
      public let settings: AppSettings
      public init(settings: AppSettings) {
        self.settings = settings
      }
    }
  }

  public enum Save {
    public struct Request: Sendable {
      public let settings: AppSettings
      public init(settings: AppSettings) {
        self.settings = settings
      }
    }
  }
}
