//
//  URLSession+appendingQueryItems.swift
//  MailClientTCA
//
//  Created by yuchekan on 16.11.2025.
//

import Foundation

nonisolated extension URL {
    func appendingQueryItems(_ items: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = (components.queryItems ?? []) + items
        return components.url!
    }
}
