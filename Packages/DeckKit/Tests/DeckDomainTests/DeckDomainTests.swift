import XCTest
import DeckDomain

final class DeckDomainTests: XCTestCase {
  func testAccountEquatable() {
    let url = URL(string: "https://example.com")!
    let first = Account(id: "1", username: "user", instanceURL: url, platform: .mastodon)
    let second = Account(id: "1", username: "user", instanceURL: url, platform: .mastodon)
    XCTAssertEqual(first, second)
  }
}
