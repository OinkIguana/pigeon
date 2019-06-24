//
//  OnlineReference.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

import Foundation

/// A reference to where this piece of content is available on the Internet
struct OnlineReference: Codable, Serializable, Deserializable, Component {
  static let version: Int64 = 1
  static let name: String = "OnlineReference"

  let url: URL
}
