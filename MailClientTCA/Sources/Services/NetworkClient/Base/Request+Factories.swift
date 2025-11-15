//
//  Request+Factories.swift
//  RuliNetwork
//
//  Created by Yuriy Chekan on 19.08.2025.
//

import Foundation

public extension Request {
    static func get(
        baseURL: String,
        endpoint: String? = nil,
        query: [String: Sendable]? = nil,
        headers: [String: String] = [:]
    ) -> Request<Response> {
        Request<Response>(method: .GET, baseURL: baseURL, endpoint: endpoint, query: query, body: nil, headers: headers)
    }

    static func post(
        baseURL: String,
        endpoint: String? = nil,
        query: [String: Sendable]? = nil,
        body: (Encodable & Sendable)?,
        headers: [String: String] = [:]
    ) -> Request<Response> {
        Request<Response>(method: .POST, baseURL: baseURL, endpoint: endpoint, query: query, body: body, headers: headers)
    }

    static func put(
        baseURL: String,
        endpoint: String? = nil,
        body: (Encodable & Sendable),
        headers: [String: String] = [:]
    ) -> Request<Response> {
        Request<Response>(method: .PUT, baseURL: baseURL, endpoint: endpoint, body: body, headers: headers)
    }

    static func delete(
        baseURL: String,
        endpoint: String? = nil,
        headers: [String: String] = [:]
    ) -> Request<Response> {
        Request<Response>(method: .DELETE, baseURL: baseURL, endpoint: endpoint, body: nil, headers: headers)
    }
    
    static func patch(
        baseURL: String,
        endpoint: String? = nil,
        query: [String: Sendable]? = nil,
        body: (Encodable & Sendable)?,
        headers: [String: String] = [:]
    ) -> Request<Response> {
        Request<Response>(
            method: .PATCH,
            baseURL: baseURL,
            endpoint: endpoint,
            query: query,
            body: body,
            headers: headers
        )
    }
}
