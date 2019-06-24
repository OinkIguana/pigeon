//
//  Signed.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation

private struct Signable<T: Codable>: Codable, Serializable, Deserializable {
  let d: T
}

struct SigningError: Error { let error: CFError }
struct VerificationError: Error { let error: CFError }

/// Signed is just a wrapper around some data with an associated digital signature. The data cannot be used until its
/// signature is verified
struct Signed<T: Codable>: Codable, Serializable, Deserializable {
  init(_ item: T) throws {
    let data = try JSONEncoder().encode(Signable(d: item))
    var error : Unmanaged<CFError>?
    let result = SecKeyCreateSignature(
      KeyPair.signing.privateKey,
      .ecdsaSignatureMessageX962SHA512,
      data as CFData,
      &error
    )
    guard let signature = result else {
      throw SigningError(error: error!.takeRetainedValue())
    }
    self.item = item
    self.signature = signature as Data
  }

  private let item: T
  private let signature: Data

  /// Verifies a signature on some data given the signer's public VerificationKey, returning the data on success only
  /// if the signature was valid using the provided key
  func verify(using verificationKey: VerificationKey) throws -> T {
    let data = try JSONEncoder().encode(Signable(d: item))
    var error : Unmanaged<CFError>?
    let valid = SecKeyVerifySignature(
      try verificationKey.secKey(),
      .ecdsaSignatureMessageX962SHA512,
      data as CFData,
      signature as CFData, &error
    )
    if !valid {
      throw VerificationError(error: error!.takeRetainedValue())
    }
    return item
  }
}
