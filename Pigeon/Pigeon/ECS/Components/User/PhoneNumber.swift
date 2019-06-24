//
//  PhoneNumber.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// A person's phone number
struct PhoneNumber: Codable, Serializable, Deserializable, Component {
  static let version: Int64 = 1
  static let name: String = "PhoneNumber"

  let number: String
}
