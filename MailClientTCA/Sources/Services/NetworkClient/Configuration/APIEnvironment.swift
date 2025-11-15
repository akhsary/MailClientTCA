//
//  Environment.swift
//  App
//
//  Created by Yuriy Chekan on 18.08.2025.
//

import Foundation

public enum APIEnvironment: String, Sendable {
    case test
    case production
    case sudir
    case sudirTest

    public var baseURL: String {
        switch self {
        case .test:
            return "https://neongrave.lol/ruli"
        case .production:
            return "https://ruli.mos.ru"
        case .sudir:
            return "https://sudir.mos.ru"
        case .sudirTest:
            return "https://sudir-test.mos.ru"
        }
    }
}
