//
//  KeyManager.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-20.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation

class RejectedClaimsError: Error {}
class NotVerifiedError: Error {}
class DuplicateKeyError: Error {}

/// Devices can issue `Claims`, in which they provide identity information which should be interpreted non-verified. It
/// is up to the receiver to verify any claims before trusting them
struct Claims: Codable, Serializable, Deserializable {
    static let mine = Claims(
        token: try! Token(),
        encryptionKey: try! Signed(EncryptionKey.mine),
        verificationKey: VerificationKey.mine
    )

    let token: Token
    let encryptionKey: Signed<EncryptionKey>
    let verificationKey: VerificationKey
}

/// The KeyManager stores an Entry for each user (Token)
///
/// The keys are tentative, until the user manually verifies the key by physically scanning the other user's QRCode
/// to retrieve their key
private enum Entry<T> {
    case verified(T)
    case tentative(T)
}

/// Very naive key manager, tracking other users and their respective verification and encryption keys. Will eventually
/// need to become a database of some sort, but it illustrates the key storing concept.
///
/// It is intended that we build a web of trust. Upon verifying one user's verification code, we can then confidently
/// trust all the keys that they have also verified, so those can be updated as well. This should be enough to quickly
/// get a community into a fully-trusted state.
///
/// In the case that there is ever an invalid entry, it means someone is a bad actor. It is not yet clear how to handle
/// this case.
enum KeyManager {
    private static var verificationKeys: [Token: Entry<VerificationKey>] = [:]
    private static var encryptionKeys: [Token: Entry<EncryptionKey>] = [:]

    /// Process some claims by performing some basic checks, and then tentatively accepting the claimed information if
    /// it is not detected to be fraud already
    static func process(claims: Claims) throws {
        switch verificationKeys[claims.token] {
        case .some(.verified(let verificationKey)) where verificationKey != claims.verificationKey:
            // immediately rejected, since we have already verified that this key is wrong
            throw RejectedClaimsError()
        case .some(.verified(let verificationKey)):
            // tentatively accept the new encryptionKey
            encryptionKeys[claims.token] = .tentative(try claims.encryptionKey.verify(using: verificationKey))
        // TODO: what to do in the case of a non-matching tentative verificationKey? Someone is doing fraud somewhere
        default:
            // tentatively accept the claims
            verificationKeys[claims.token] = .tentative(claims.verificationKey)
        }
    }

    static func insert(_ token: Token, encryptionKey: Signed<EncryptionKey>) throws {
        switch verificationKeys[token] {
        case .some(.verified(let verificationKey)):
            encryptionKeys[token] = .verified(try encryptionKey.verify(using: verificationKey))
        case .some(.tentative(let verificationKey)):
            encryptionKeys[token] = .tentative(try encryptionKey.verify(using: verificationKey))
        case .none:
            throw NotVerifiedError()
        }
    }

    static func getVerifiedKeys(for token: Token) -> (verification: VerificationKey?, encryption: EncryptionKey?) {
        switch (verificationKeys[token], encryptionKeys[token]) {
        case let (.some(.verified(verification)), .some(.verified(encryption))):
            return (verification: verification, encryption: encryption)
        case let (.some(.verified(verification)), _):
            return (verification: verification, encryption: nil)
        case let (_, .some(.verified(encryption))):
            return (verification: nil, encryption: encryption)
        default:
            return (verification: nil, encryption: nil)
        }
    }
}
