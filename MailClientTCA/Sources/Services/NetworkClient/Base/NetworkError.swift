//
//  NetworkError.swift
//  App
//
//  Created by Yuriy Chekan on 18.08.2025.
//

import Foundation

nonisolated
public enum NetworkError: Error {
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case decodingError
    case invalidURL
    case authenticationRequired
    case emptyError

    public var errorDescription: String {
        switch self {
        case .networkError(let error):
            return "Что-то пошло не так:" + error.localizedDescription
        case .invalidResponse:
            return "Неудалось получить ответ от сервера"
        case .httpError(let code):
            return "Неверный статус код: " + String(code)
        case .decodingError:
            return "Ошибка декодирования"
        case .invalidURL:
            return "Invalid URL"
        case .emptyError:
            return ""
        case .authenticationRequired:
            return "Authentication required"
        }
    }
}
