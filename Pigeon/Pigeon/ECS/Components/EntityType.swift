//
//  EntityType.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// What this entity is representing
enum EntityType: Codable, Serializable, Deserializable, Component {
    static let name: String = "EntityType"

    case user
    case post
    case unknown(String)

    var rawValue: String {
        switch self {
        case .user: return "user"
        case .post: return "post"
        case .unknown(let rawValue): return rawValue
        }
    }

    init(from decoder: Decoder) throws {
        let type = try decoder.singleValueContainer().decode(String.self)
        switch type {
        case EntityType.user.rawValue: self = .user
        case EntityType.post.rawValue: self = .post
        default: self = .unknown(type)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
