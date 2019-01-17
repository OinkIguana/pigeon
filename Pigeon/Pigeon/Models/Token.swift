//
//  Token.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation
import Security

/// A `Token` is a random set of bytes.
///
/// Each user is assigned one token, which can then be used to identify them universally.
///
/// Tokens are also used to represent posts and other content shared by users.
struct Token: Codable, Equatable, Hashable, SecureStorable {
    static let storageKey: String = "IdentityToken"
    private static let length = 384

    /// Retrieves the current device's token
    static let mine: Token = {
        if let existing: Token = try! Storage.retrieve() {
            return existing
        } else {
            let token = try! Token()
            try! Storage.store(token)
            return token
        }
    }()

    init() throws {
        token = try Data.secureRandom(bytes: Token.length).base64EncodedString()
    }

    init(from decoder: Decoder) throws {
        token = try decoder.singleValueContainer().decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(token)
    }

    private let token: String
}
