//
//  Serializer.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-20.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation

/// Describes types that can be serialized
protocol Serializable: Encodable {}

/// Describes types that can be deserialized
protocol Deserializable: Decodable {}

/// A Serializer can serialize codable types into Data. Similar to Encoder but with a better interface
protocol Serializer {
  /// Serialize the item into data
  func serialize<T: Serializable>(_ item: T) throws -> Data
}

/// A Deserializer can deserialize codable types from Data. Similar to Decoder but with a better interface
protocol Deserializer {
  /// Deserialize the data into a type
  func deserialize<T: Deserializable>(_ type: T.Type, from data: Data) throws -> T
}

/// A hack until fragments are codable
private struct Container<T> {
  let value: T
}
extension Container: Encodable where T: Encodable {}
extension Container: Decodable where T: Decodable {}

extension JSONEncoder: Serializer {
  func serialize<T: Serializable>(_ item: T) throws -> Data {
    return try encode(Container(value: item))
  }
}

extension JSONDecoder: Deserializer {
  func deserialize<T: Deserializable>(_ type: T.Type, from data: Data) throws -> T {
    return try decode(Container<T>.self, from: data).value
  }
}
