//
//  FullName.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

import Foundation

/// A person's full name
struct FullName: Codable, Serializable, Deserializable, Component {
  static let version: Int64 = 1
  static let name: String = "FullName"

  let fullName: String

  var firstName: String {
    return String(fullName.split(separator: " ", omittingEmptySubsequences: true).first!)
  }

  var lastName: String {
    return String(fullName.split(separator: " ", omittingEmptySubsequences: true).last!)
  }
}
