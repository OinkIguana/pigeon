//
//  Entty.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-06.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// An entity in the entity-component-system. It's just an ID, which can be shared between devices to represent the same
/// entity. An Entity can represent any piece of data in the system, including users, posts, etc.
struct Entity: Codable, Serializable, Hashable, Deserializable {
    static let me: Entity = Entity(id: Token.mine)

    let id: Token
}
