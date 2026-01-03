import SwiftUI

public struct ErrorBanner: View {
  public let message: String

  public init(message: String) {
    self.message = message
  }

  public var body: some View {
    Text(message)
      .font(.subheadline)
      .foregroundStyle(.white)
      .padding(.vertical, 8)
      .padding(.horizontal, 12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.red.opacity(0.85))
      .cornerRadius(8)
      .padding(.horizontal)
  }
}

public struct EmptyStateView: View {
  public let title: String
  public let subtitle: String

  public init(title: String, subtitle: String) {
    self.title = title
    self.subtitle = subtitle
  }

  public var body: some View {
    VStack(spacing: 8) {
      Text(title)
        .font(.headline)
      Text(subtitle)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
  }
}
