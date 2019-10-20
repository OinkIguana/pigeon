//
//  Box.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

/// Wraps a type to give it reference semantics, even as a struct
class Box<T: Codable>: Codable {
  let data: T
  init(data: T) { self.data = data }
}

extension Box: Equatable where T: Equatable {
  static func == (lhs: Box<T>, rhs: Box<T>) -> Bool { lhs.data == rhs.data }
}

extension Box: Hashable where T: Hashable {
  func hash(into hasher: inout Hasher) { data.hash(into: &hasher) }
}

extension Box: Comparable where T: Comparable {
  static func < (lhs: Box<T>, rhs: Box<T>) -> Bool { lhs.data < rhs.data }
}

extension Box: Identifiable where T: Identifiable {
  var id: T.ID { data.id }
}
