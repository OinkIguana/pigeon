//
//  Storage.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-12.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import Foundation
import Valet

// MARK: - Storage Key

protocol StorageKey {
  associatedtype V: Codable
  static var key: String { get }
}

extension StorageKey {
  static var key: String { String(describing: Self.self) }
}

// MARK: - Secure Storage Key

protocol SecureStorageKey {
  associatedtype V: Codable
  static var key: String { get }
}

extension SecureStorageKey {
  static var key: String { String(describing: Self.self) }
}

// MARK: - Storage

/// Type safe wrapper around the User Defaults and Keychain
enum Storage {
  static private let valet = Valet.valet(with: Identifier(nonEmpty: "Pigeon")!, accessibility: .whenUnlocked)

  // MARK: User Defaults

  static func contains<K: StorageKey>(_ key: K.Type) -> Bool {
    return UserDefaults.standard.data(forKey: K.key) != nil
  }

  static func store<K: StorageKey>(value: K.V, for key: K.Type) {
    let json = try! JSONEncoder().encode(Box(v: value))
    UserDefaults.standard.set(json, forKey: K.key)
  }

  static func retrieve<K: StorageKey>(_ key: K.Type) -> K.V? {
    if let data = UserDefaults.standard.data(forKey: K.key) {
      return (try? JSONDecoder().decode(Box<K.V>.self, from: data))?.v
    } else {
      return nil
    }
  }

  static func remove<K: StorageKey>(_ key: K.Type) {
    UserDefaults.standard.removeObject(forKey: key.key)
  }

  // MARK: Keychain

  static func contains<K: SecureStorageKey>(_ key: K.Type) -> Bool {
    return retrieve(key) != nil
  }

  static func store<K: SecureStorageKey>(value: K.V, for key: K.Type) {
    let json = try! JSONEncoder().encode(Box(v: value))
    valet.set(object: json, forKey: K.key)
  }

  static func retrieve<K: SecureStorageKey>(_ key: K.Type) -> K.V? {
    if let data = valet.object(forKey: K.key) {
      return (try? JSONDecoder().decode(Box<K.V>.self, from: data))?.v
    } else {
      return nil
    }
  }

  static func remove<K: SecureStorageKey>(_ key: K.Type) {
    valet.removeObject(forKey: K.key)
  }
}
