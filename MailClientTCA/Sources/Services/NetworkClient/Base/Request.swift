//
//  Request.swift
//  Network
//
//  Created by Yuriy Chekan on 18.08.2025.
//

import Foundation

nonisolated
public struct Request<Response>: Sendable {
    public let method: HTTPMethod
    public let baseURL: String
    public let endpoint: String?
    public let query: [String: Sendable]?
    public let body: (Encodable & Sendable)?
    public let headers: [String: String]

    public init(
        method: HTTPMethod,
        baseURL: String,
        endpoint: String?,
        query: [String: Sendable]? = nil,
        body: (Encodable & Sendable)? = nil,
        headers: [String: String] = [:]
    ) {
        self.method = method
        self.baseURL = baseURL
        self.endpoint = endpoint
        self.query = query
        self.body = body
        self.headers = headers
    }
}
