import Foundation

public struct NetworkClient: Sendable {
  private let urlSession: URLSession

  public init(urlSession: URLSession) {
    self.urlSession = urlSession
  }

  public func send<Request: Encodable, Response: Decodable>(url: URL, method: String, body: Request? = nil, headers: [String: String] = [:]) async throws -> Response {
    var request = URLRequest(url: url)
    request.httpMethod = method
    headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
    if let body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      let encoder = JSONEncoder()
      request.httpBody = try encoder.encode(body)
    }

    let (data, response) = try await urlSession.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
      throw AuthenticationError.unexpectedResponse
    }
    let decoder = JSONDecoder()
    return try decoder.decode(Response.self, from: data)
  }

  public func sendForm<Response: Decodable>(url: URL, body: [String: String]) async throws -> Response {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    let bodyString = body
      .map { key, value in
        "\(key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)"
      }
      .joined(separator: "&")
    request.httpBody = bodyString.data(using: .utf8)

    let (data, response) = try await urlSession.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
      throw AuthenticationError.unexpectedResponse
    }
    let decoder = JSONDecoder()
    return try decoder.decode(Response.self, from: data)
  }

  public func sendEmpty<Request: Encodable>(url: URL, method: String, body: Request? = nil, headers: [String: String] = [:]) async throws {
    var request = URLRequest(url: url)
    request.httpMethod = method
    headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
    if let body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      let encoder = JSONEncoder()
      request.httpBody = try encoder.encode(body)
    }

    let (_, response) = try await urlSession.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
      throw AuthenticationError.unexpectedResponse
    }
  }
}
