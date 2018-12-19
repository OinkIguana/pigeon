//
//  Token.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation
import Security

/// A `Token` is a cryptographically secure random token. Each user is assigned one token, which can then be used to
/// identify them universally.
///
/// On it's own, it provides no security/authenticity guarantees. It is simply a very long and hard to reproduce
/// identifier.
struct Token: Codable, Equatable, SecureStorable {
    static let storageKey: String = "IdentityToken"
    private static let length = 384

    init() throws {
        if let existing: Token = try Storage.retrieve() {
            self = existing
        } else {
            token = try Data.secureRandom(bytes: Token.length).base64EncodedString()
        }
    }

    private let token: String
}
