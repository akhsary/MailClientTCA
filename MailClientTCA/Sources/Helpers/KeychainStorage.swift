//
//  KeychainStorage.swift
//  MailClientTCA
//
//  Created by yuchekan on 15.11.2025.
//

import Foundation
import Security
import SwiftUI

nonisolated
final class _KeychainStorage: Sendable {
    static let shared = _KeychainStorage()
    
    private init() {}
    
    enum KeychainError: Error {
        case itemAlreadyExist
        case itemNotFound
        case errorStatus(String?)

        init(status: OSStatus) {
            switch status {
            case errSecDuplicateItem:
                self = .itemAlreadyExist
            case errSecItemNotFound:
                self = .itemNotFound
            default:
                let message = SecCopyErrorMessageString(status, nil) as String?
                self = .errorStatus(message)
            }
        }
    }

    func addItem(query: [CFString: Any]) throws {
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    func findItem(query: [CFString: Any]) throws -> [CFString: Any]? {
        var query = query
        query[kSecReturnAttributes] = kCFBooleanTrue
        query[kSecReturnData] = kCFBooleanTrue

        var searchResult: AnyObject?

        let status = withUnsafeMutablePointer(to: &searchResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }

        if status != errSecSuccess {
            throw KeychainError(status: status)
        } else {
            return searchResult as? [CFString: Any]
        }
    }

    func updateItem(query: [CFString: Any], attributesToUpdate: [CFString: Any]) throws {
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    func deleteItem(query: [CFString: Any]) throws {
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
}

nonisolated
extension _KeychainStorage {
    func addPassword(_ password: String, for account: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account
        query[kSecValueData] = password.data(using: .utf8)

        do {
            try addItem(query: query)
        } catch {
            return
        }
    }

    func updatePassword(_ password: String, for account: String) {
        guard let _ = getPassword(for: account) else {
            addPassword(password, for: account)
            return
        }

        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account

        var attributesToUpdate: [CFString: Any] = [:]
        attributesToUpdate[kSecValueData] = password.data(using: .utf8)

        do {
            try updateItem(query: query, attributesToUpdate: attributesToUpdate)
        } catch {
            return
        }
    }

    func getPassword(for account: String) -> String? {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account

        var result: [CFString: Any]?

        do {
            result = try findItem(query: query)
        } catch {
            return nil
        }

        if let data = result?[kSecValueData] as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    func deletePassword(for account: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrAccount] = account

        do {
            try deleteItem(query: query)
        } catch {
            return
        }
    }
}

@propertyWrapper
nonisolated
public struct KeychainStorage: DynamicProperty, Sendable {
    nonisolated private let label: String
    nonisolated private let storage = _KeychainStorage.shared

    nonisolated public init(_ label: String) {
        self.label = label
    }

    nonisolated public var wrappedValue: String? {
        get {
            storage.getPassword(for: label)
        }
        
        nonmutating set {
            if let newValue = newValue {
                storage.updatePassword(newValue, for: label)
            } else {
                storage.deletePassword(for: label)
            }
        }
    }
}

