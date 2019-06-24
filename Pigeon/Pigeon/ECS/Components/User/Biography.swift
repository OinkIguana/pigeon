//
//  Biography.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// A person's self-written biography, as shown on a profile
struct Biography: Codable, Serializable, Deserializable, Component {
  static let version: Int64 = 1
  static let name: String = "Biography"

  let body: String
}
