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
/// from the other user, as the encryption key must change periodically
struct EncryptionKey: Codable {
    private let token: Token
    private let encryptionKey: String

    init(from secKey: SecKey) throws {
        token = try Token()
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(secKey, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        encryptionKey = (data as Data).base64EncodedString()
    }

    func secKey() throws -> SecKey {
        let options: [String: Any] = [
            kSecAttrType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 256,
        ]
        var error : Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(
            Data(base64Encoded: encryptionKey)! as CFData,
            options as CFDictionary,
            &error
        ) else {
            throw EncryptionError(error: error!.takeRetainedValue())
        }
        return secKey
    }
}

