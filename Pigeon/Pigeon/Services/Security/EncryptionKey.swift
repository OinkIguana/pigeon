//
//  EncryptionKey.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation
import Security

/// An `EncryptionKey` encapsulates another user's public encryption key. It is expected that these are retrieved often
/// from the other user, as the encryption key must change periodically. TODO: find a mechanism to track the TTL of
/// the keys, discard expired keys, and regenerate your own expired key.
struct EncryptionKey: Codable, Equatable {
    init(from decoder: Decoder) throws {
        encryptionKey = try decoder.singleValueContainer().decode(Data.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(encryptionKey)
    }

    static let mine = try! EncryptionKey(from: KeyPair.encryption.publicKey)

    private let encryptionKey: Data

    init(from secKey: SecKey) throws {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(secKey, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        encryptionKey = data as Data
    }

    func secKey() throws -> SecKey {
        let options: [String: Any] = [
            kSecAttrType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 256,
        ]
        var error : Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(
            encryptionKey as CFData,
            options as CFDictionary,
            &error
        ) else {
            throw EncryptionError(error: error!.takeRetainedValue())
        }
        return secKey
    }
}

