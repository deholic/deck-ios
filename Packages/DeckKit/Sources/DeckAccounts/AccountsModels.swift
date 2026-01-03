import Foundation
import DeckServices

enum AccountsModels {
  enum Load {
    struct Response {
      let accounts: [Account]
    }

    struct ViewModel {
      let accounts: [AccountRow]
    }
  }

  enum Add {
    struct Response {
      let account: Account
    }

    struct ViewModel {
      let account: AccountRow
    }
  }

  enum ErrorState {
    struct ViewModel {
      let message: String
    }
  }
}

struct AccountRow: Identifiable, Equatable {
  let id: UUID
  let title: String
  let subtitle: String

  init(account: Account) {
    id = account.id
    title = "@\(account.username)"
    subtitle = "\(account.service.displayName) · \(account.instance.host ?? account.instance.absoluteString)"
  }
}
