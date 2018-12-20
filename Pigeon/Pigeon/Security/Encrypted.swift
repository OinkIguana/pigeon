//
//  EncryptedData.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation

struct EncryptionError: Error { let error: CFError }
struct DecryptionError: Error { let error: CFError }

/// Encrypted wraps the raw encrypted data to indicate that it has been encrypted and must be decrypted before
/// meaningful usage
struct Encrypted<T: Codable>: Codable {
    init(item: T, using encryptionKey: EncryptionKey) throws {
        let plaintext = try JSONEncoder().encode(item)
        var error: Unmanaged<CFError>?
        let result = SecKeyCreateEncryptedData(
            try encryptionKey.secKey(),
            .eciesEncryptionStandardX963SHA512AESGCM,
            plaintext as CFData,
            &error
        )
        guard let ciphertext = result else {
            throw EncryptionError(error: error!.takeRetainedValue())
        }
        self.ciphertext = ciphertext as Data
    }

    private let ciphertext: Data

    /// Attempts to decrypt some data using your own private decryption key
    func decrypt() throws -> T {
        var error: Unmanaged<CFError>?
        let result = SecKeyCreateDecryptedData(
            KeyPair.encryption.privateKey,
            .eciesEncryptionStandardX963SHA512AESGCM,
            ciphertext as CFData,
            &error
        )
        guard let plaintext = result else {
            throw DecryptionError(error: error!.takeRetainedValue())
        }
        return try JSONDecoder().decode(T.self, from: plaintext as Data)
    }
}
