//
//  NetworkClient.swift
//  App
//
//  Created by Yuriy Chekan on 18.08.2025.
//

import Foundation
import SwiftUI

public actor NetworkClient {
    @KeychainStorage("access_token")
    private var accessToken

    private nonisolated let session: URLSession

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .init(),
        encoder: JSONEncoder = .init()
    ) {
        self.session = session
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .formatted(formatter)
        self.encoder = encoder
        self.encoder.dateEncodingStrategy = .formatted(formatter)
    }

    // MARK: - Send request with response
    public func send<Response: Decodable & Sendable>(
        _ request: Request<Response>,
        raw: Bool = false
    ) async throws -> Response {
        try await sendWithRetry(request) { data in
            try await self.decode(data, expecting: Response.self, raw: raw)
        }
    }

    // MARK: - Send request without response
    public func send(_ request: Request<Void>) async throws {
        try await sendWithRetry(request, { _ in })
    }

    // MARK: - Private API
    // TODO: No retry for now, add later
    private func sendWithRetry<Response>(
        _ request: Request<Response>,
        _ decode: @escaping (Data) async throws -> Response,
        retryCount: Int = 1
    ) async throws -> Response {
        for attempt in 0...retryCount {
            return try await send(request, decode)
        }
        throw NetworkError.emptyError
    }

    private func send<Response>(_ request: Request<Response>,
                                _ decode: @escaping (Data) async throws -> Response) async throws -> Response {
        let urlRequest = try await makeURLRequest(for: request)
        let (data, response) = try await send(urlRequest)
        do {
            try validate(response: response)
        } catch {
            if let netError = error as? NetworkError {
                if case .httpError(403) = netError {
                    throw netError
                }
            }
        }
        return try await decode(data)
    }

    private func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request, delegate: nil)
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    private func decode<T: Decodable & Sendable>(
        _ data: Data,
        expecting: T.Type = T.self,
        raw: Bool
    ) async throws -> T {
        // Если просим «сырые байты» — отдаём только для Data
        if raw {
            if T.self == Data.self {
                return data as! T
            } else {
                #if DEBUG
                print("DEBUG: raw==true, но ожидаемый тип не Data (\(T.self))")
                #endif
                throw NetworkError.decodingError
            }
        }

        // Обычное поведение (JSON/String)
        do {
            return try await Task.detached { [decoder] in
                if T.self == String.self {
                    guard let string = String(data: data, encoding: .utf8) as? T else {
                        throw NetworkError.decodingError
                    }
                    return string
                } else {
                    return try decoder.decode(T.self, from: data)
                }
            }.value
        } catch {
            #if DEBUG
            print("DEBUG: \(error)")
            #endif
            throw NetworkError.decodingError
        }
    }
    
    private func decode<T: Decodable & Sendable>(_ data: Data) async throws -> T {
        try await decode(data, expecting: T.self, raw: false)
    }

    private func makeURLRequest<Response>(for request: Request<Response>) async throws -> URLRequest {
        var urlRequest = URLRequest(url: try buildURL(baseURL: request.baseURL, endpoint: request.endpoint, query: request.query))
        urlRequest.httpMethod = request.method.rawValue

        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let body = request.body {
            if let body = body as? Data {
                urlRequest.httpBody = body
            } else {
                urlRequest.httpBody = try await Task.detached { [encoder] in
                    try encoder.encode(body)
                }.value

                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            }
        }

        if urlRequest.value(forHTTPHeaderField: "Accept") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        if urlRequest.value(forHTTPHeaderField: "Authorization") == nil,
           let accessToken = accessToken {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return urlRequest
    }

    private func buildURL(baseURL: String, endpoint: String?, query: [String: Sendable]?) throws -> URL {
        guard var url = URL(string: baseURL) else { throw NetworkError.invalidURL }
        if let endpoint = endpoint {
            url.appendPathComponent(endpoint)
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if let query {
            var queryItems: [URLQueryItem] = []
            
            query.forEach { key, value in
                if let stringValue = value as? String {
                    queryItems.append(URLQueryItem(name: key, value: stringValue))
                } else if let arrayValue = value as? [String] {
                    for item in arrayValue {
                        queryItems.append(URLQueryItem(name: key, value: item))
                    }
                }
            }
            
            components?.queryItems = queryItems
        }

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }

        return finalURL
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
}

extension NetworkClient {
    public static var liveValue: NetworkClient {
        .init()
    }
}

