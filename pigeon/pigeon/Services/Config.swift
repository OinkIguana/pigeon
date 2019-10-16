//
//  Config.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-15.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import Foundation

// MARK: - ConfigKey

protocol ConfigKey {
  associatedtype Data
  static var key: String { get }
}

extension ConfigKey {
  static var key: String { String(describing: Self.self) }
}

// MARK: - Config

/// A type safe wrapper around Config.plist
enum Config {
  private static let config: NSDictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Config", ofType: "plist")!)!
  static func retrieve<K: ConfigKey>(_ key: K.Type) -> K.Data { config.object(forKey: K.key) as! K.Data }

  enum BackgroundAuthenticationDuration: ConfigKey {
    typealias Data = Double
  }
}
