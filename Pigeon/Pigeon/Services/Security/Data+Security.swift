//
//  Data+Security.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation
import CryptoSwift

struct SecureRandomDataError: Error {}

extension Data {
  /// Generate some random data using the cryptographically secure random generator
  static func secureRandom(bytes length: Int) throws -> Data {
    var data = [UInt8](repeating: 0, count: length)
    guard SecRandomCopyBytes(kSecRandomDefault, length, &data) == errSecSuccess else {
      throw SecureRandomDataError()
    }
    return Data(data)
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
