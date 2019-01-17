//
//  Email.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// A person's email
struct Email: Codable, Serializable, Deserializable, Component {
    static let name: String = "Email"

    let email: String
}
