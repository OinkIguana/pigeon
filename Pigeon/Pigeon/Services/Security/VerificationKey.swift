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
struct VerificationKey: Codable, Equatable {
    init(from decoder: Decoder) throws {
        verificationKey = try decoder.singleValueContainer().decode(Data.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(verificationKey)
    }

    static let mine = try! VerificationKey(from: KeyPair.signing.publicKey)

    private let verificationKey: Data

    init(from secKey: SecKey) throws {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(secKey, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        verificationKey = data as Data
    }

    func secKey() throws -> SecKey {
        let options: [String: Any] = [
            kSecAttrType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 256,
        ]
        var error : Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(
            verificationKey as CFData,
            options as CFDictionary,
            &error
        ) else {
            throw VerificationError(error: error!.takeRetainedValue())
        }
        return secKey
    }

    /// Renders the verification key as a QRCode, which can be displayed for users to manually transfer to each other.
    /// This will be the primary method of trusted key-sharing.
    ///
    /// Be sure to document well to the user only to scan *trusted* QR codes, directly from the phone they are expecting
    /// to scan from. Do not print or scan printed QR codes, as they are more likely to be malicious.
    func render() throws -> QRCode {
        let data = try JSONEncoder().encode(self)
        return QRCode(data)
    }
}
