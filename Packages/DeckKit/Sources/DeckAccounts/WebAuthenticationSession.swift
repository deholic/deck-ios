import AuthenticationServices
import DeckServices
import UIKit

final class WebAuthenticationSession: NSObject, ASWebAuthenticationPresentationContextProviding {
  private var session: ASWebAuthenticationSession?

  func start(url: URL, callbackScheme: String) async throws -> URL {
    try await withCheckedThrowingContinuation { continuation in
      let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { callbackURL, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }
        guard let callbackURL else {
          continuation.resume(throwing: AuthenticationError.invalidCallbackURL)
          return
        }
        continuation.resume(returning: callbackURL)
      }
      session.presentationContextProvider = self
      session.prefersEphemeralWebBrowserSession = true
      self.session = session
      session.start()
    }
  }

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first else {
      return UIWindow()
    }
    return window
  }
}
