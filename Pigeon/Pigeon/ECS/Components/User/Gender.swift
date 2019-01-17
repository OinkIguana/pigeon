//
//  Gender.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// A person's gender
enum Gender: Codable, Serializable, Deserializable, Component {
    static let name: String = "Gender"

    case male
    case female
    case other(String)

    var rawValue: String {
        switch self {
        case .male: return "male"
        case .female: return "female"
        case .other(let rawValue): return rawValue
        }
    }

    init(from decoder: Decoder) throws {
        let type = try decoder.singleValueContainer().decode(String.self)
        switch type {
        case Gender.male.rawValue: self = .male
        case Gender.female.rawValue: self = .female
        default: self = .other(type)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
