import Foundation

public struct InstanceURLParser {
  public init() {}

  public func parse(_ value: String) -> URL? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }

    if let url = URL(string: trimmed), url.scheme != nil {
      return url
    }

    return URL(string: "https://\(trimmed)")
  }
}
