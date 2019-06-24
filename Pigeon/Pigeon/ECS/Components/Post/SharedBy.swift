//
//  SharedBy.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// A reference to the user who owns this piece of content
struct SharedBy: Codable, Serializable, Deserializable, Component {
  static let version: Int64 = 1
  static let name: String = "SharedBy"

  let token: Token
}
