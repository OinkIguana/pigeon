//
//  Author.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// The person who created the content (not necessarily the same person as who shared it)
struct Author: Codable, Serializable, Deserializable, Component {
  static let version: Int64 = 1
  static let name: String = "Author"

  let token: Token
}
