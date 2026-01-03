import Foundation

public protocol AccountStorage: Sendable {
  func loadAccounts() throws -> [Account]
  func saveAccounts(_ accounts: [Account]) throws
}

public final class UserDefaultsAccountStorage: AccountStorage, @unchecked Sendable {
  private let userDefaults: UserDefaults
  private let key = "deck.accounts.storage"
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  public init(userDefaults: UserDefaults) {
    self.userDefaults = userDefaults
    encoder.dateEncodingStrategy = .iso8601
    decoder.dateDecodingStrategy = .iso8601
  }

  public func loadAccounts() throws -> [Account] {
    guard let data = userDefaults.data(forKey: key) else { return [] }
    do {
      return try decoder.decode([Account].self, from: data)
    } catch {
      userDefaults.removeObject(forKey: key)
      return []
    }
  }

  public func saveAccounts(_ accounts: [Account]) throws {
    let data = try encoder.encode(accounts)
    userDefaults.set(data, forKey: key)
  }
}

public actor AccountStore {
  private let storage: AccountStorage

  public init(storage: AccountStorage) {
    self.storage = storage
  }

  public func loadAccounts() async throws -> [Account] {
    try storage.loadAccounts()
  }

  public func addAccount(_ account: Account) async throws {
    var accounts = try storage.loadAccounts()
    accounts.append(account)
    try storage.saveAccounts(accounts)
  }

  public func removeAccount(id: String) async throws {
    var accounts = try storage.loadAccounts()
    accounts.removeAll { $0.id == id }
    try storage.saveAccounts(accounts)
  }
}
