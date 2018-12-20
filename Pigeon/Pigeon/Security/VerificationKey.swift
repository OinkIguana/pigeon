//
//  VerificationKey.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation
import Security
import QRCode

/// A `VerificationKey` encapsulates another user's public verification key. It is expected that these are transmitted
/// manually by users, effictively adding them to their "friends list"
struct VerificationKey: Codable {
    private let token: Token
    private let verificationKey: String

    init(from secKey: SecKey) throws {
        token = try Token()
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(secKey, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        verificationKey = (data as Data).base64EncodedString()
    }

    func secKey() throws -> SecKey {
        let options: [String: Any] = [
            kSecAttrType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 256,
        ]
        var error : Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(
            Data(base64Encoded: verificationKey)! as CFData,
            options as CFDictionary,
            &error
        ) else {
            throw VerificationError(error: error!.takeRetainedValue())
        }
        return secKey
    }

    /// Renders the verification key as a QRCode, which can be displayed for users to manually transfer to each other
    func render() throws -> QRCode {
        let data = try JSONEncoder().encode(self)
        return QRCode(data)
    }
}
