import Foundation
import DeckServices

enum ComposeModels {
  enum Load {
    struct Response {
      let accounts: [Account]
    }

    struct ViewModel {
      let accounts: [ComposeAccountRow]
      let selectedAccountId: UUID?
    }
  }

  enum Submit {
    struct Request {
      let text: String
      let visibility: PostingVisibility
      let accountId: UUID?
    }

    struct Response {
      let message: String
    }

    struct ViewModel {
      let message: String
    }
  }

  enum ErrorState {
    struct ViewModel {
      let message: String
    }
  }
}

struct ComposeAccountRow: Identifiable, Equatable {
  let id: UUID
  let title: String
  let subtitle: String
  let service: AccountServiceType

  init(account: Account) {
    id = account.id
    title = "@\(account.username)"
    subtitle = "\(account.service.displayName) · \(account.instance.host ?? account.instance.absoluteString)"
    service = account.service
  }
}
