//
//  Data+Security.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation
import Security
import LocalAuthentication
import CryptoSwift

struct SecureRandomDataError: Error {}
struct KeyGenerationError: Error {}
struct KeySavingError: Error {}
struct SigningError: Error { let error: CFError }
struct VerificationError: Error { let error: CFError }
struct EncryptionError: Error { let error: CFError }
struct DecryptionError: Error { let error: CFError }

extension Data {
    private static func keyPair(_ publicLabel: String, _ privateLabel: String) throws -> (public: SecKey, private: SecKey) {
        let context = LAContext()

        // attempt to retrieve existing keys
        let getPublicKey: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrLabel as String: publicLabel,
            kSecReturnRef as String: true,
        ]

        let getPrivateKey: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrLabel as String: privateLabel,
            kSecReturnRef as String: true,
            kSecUseAuthenticationContext as String: context,
        ]

        var rawPublic: CFTypeRef?
        let publicStatus = SecItemCopyMatching(getPublicKey as CFDictionary, &rawPublic)
        var rawPrivate: CFTypeRef?
        let privateStatus = SecItemCopyMatching(getPrivateKey as CFDictionary, &rawPrivate)
        if
            publicStatus == errSecSuccess,
            privateStatus == errSecSuccess,
            let publicKey = rawPublic,
            let privatekey = rawPrivate
        {
            return (public: publicKey as! SecKey, private: privatekey  as! SecKey)
        }

        // generate new keys
        var error: Unmanaged<CFError>?
        guard let privateAccessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            [SecAccessControlCreateFlags.userPresence, .privateKeyUsage],
            &error
        ) else {
            throw error!.takeRetainedValue()
        }

        guard let publicAccessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleAlwaysThisDeviceOnly,
            [],
            &error
        ) else {
            throw error!.takeRetainedValue()
        }

        let privateKeyParams: [String: Any] = [
            kSecAttrLabel as String: privateLabel,
            kSecAttrIsPermanent as String: true,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIAllow,
            kSecUseAuthenticationContext as String: context,
            kSecAttrAccessControl as String: privateAccessControl,
        ]

        let publicKeyParams: [String: Any] = [
            kSecAttrLabel as String: publicLabel,
            kSecAttrAccessControl as String: publicAccessControl,
        ]

        let params: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecPrivateKeyAttrs as String: privateKeyParams,
            kSecPublicKeyAttrs as String: publicKeyParams,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave
        ]

        var publicSec, privateSec: SecKey!
        guard SecKeyGeneratePair(params as CFDictionary, &publicSec, &privateSec) == errSecSuccess else {
            throw KeyGenerationError()
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrLabel as String: publicLabel,
            kSecValueRef as String: publicSec,
        ]

        var raw: CFTypeRef?
        var status = SecItemAdd(query as CFDictionary, &raw)
        if status == errSecDuplicateItem {
            status = SecItemDelete(query as CFDictionary)
            status = SecItemAdd(query as CFDictionary, &raw)
        }
        guard status == errSecSuccess else {
            throw KeySavingError()
        }

        return (public: publicSec, private: privateSec)
    }

    private static let signingKeys: (public: SecKey, private: SecKey) = try! keyPair("pigeon.signing.pub", "pigeon.signing")
    private static let encryptionKeys: (public: SecKey, private: SecKey) = try! keyPair("pigeon.encryption.pub", "pigeon.encryption")

    /// Get your public VerificationKey
    static func verificationKey() throws -> VerificationKey {
        return try VerificationKey(from: Data.signingKeys.public)
    }

    /// Get your public EncryptionKey
    static func encryptionKey() throws -> EncryptionKey {
        return try EncryptionKey(from: Data.encryptionKeys.public)
    }

    /// Generate some random data using the cryptographically secure random generator
    static func secureRandom(bytes length: Int) throws -> Data {
        var data = [UInt8](repeating: 0, count: length)
        guard SecRandomCopyBytes(kSecRandomDefault, length, &data) == errSecSuccess else {
            throw SecureRandomDataError()
        }
        return Data(data)
    }

    /// Computes the signature of this data, signed with your own private signing key
    func signature() throws -> Data {
        var error : Unmanaged<CFError>?
        let result = SecKeyCreateSignature(Data.signingKeys.private, .ecdsaSignatureMessageX962SHA512, self as CFData, &error)
        guard let signature = result else {
            throw SigningError(error: error!.takeRetainedValue())
        }
        return signature as Data
    }

    /// Verifies a signature on some data given the signer's public VerificationKey
    func verify(signature: Data, using verificationKey: VerificationKey) throws {
        var error : Unmanaged<CFError>?
        let valid = SecKeyVerifySignature(try verificationKey.secKey(), .ecdsaSignatureMessageX962SHA512, self as CFData, signature as CFData, &error)
        if !valid {
            throw VerificationError(error: error!.takeRetainedValue())
        }
    }

    /// Computes the encryption of this data using the decoder's public EncryptionKey
    func encrypt(with encryptionKey: EncryptionKey) throws -> Data {
        var error: Unmanaged<CFError>?
        let result = SecKeyCreateEncryptedData(try encryptionKey.secKey(), .eciesEncryptionStandardX963SHA512AESGCM, self as CFData, &error)
        guard let data = result else {
            throw EncryptionError(error: error!.takeRetainedValue())
        }
        return data as Data
    }

    /// Attempts to decrypt some data using your own private decryption key
    func decrypt() throws -> Data {
        var error: Unmanaged<CFError>?
        let result = SecKeyCreateDecryptedData(Data.encryptionKeys.private, .eciesEncryptionStandardX963SHA512AESGCM, self as CFData, &error)
        guard let data = result else {
            throw DecryptionError(error: error!.takeRetainedValue())
        }
        return data as Data
    }

    /// Encrypts some data symmetrically (using AES), returning the encrypted data along with the randomly generated key
    /// and IV
    func encryptSymmetric() throws -> (Data, key: Data, iv: Data) {
        let key = try Data.secureRandom(bytes: 32)
        let iv = try Data.secureRandom(bytes: 16)
        let aes = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes))
        let encrypted = Data(try aes.encrypt(bytes))
        return (encrypted, key: key, iv: iv)
    }

    /// Decrypts some symmetrically encrypted data (using AES) with the provided key and IV
    func decryptSymmetric(key: Data, iv: Data) throws -> Data {
        let aes = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes))
        return Data(try aes.decrypt(bytes))
    }
}
