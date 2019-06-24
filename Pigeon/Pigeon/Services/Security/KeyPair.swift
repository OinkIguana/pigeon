//
//  KeyPair.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation
import Security
import LocalAuthentication

struct KeyGenerationError: Error {}
struct KeySavingError: Error {}

struct KeyPair {
  private static let context = LAContext()

  static let encryption = try! KeyPair(name: "pigeon.encryption")
  static let signing = try! KeyPair(name: "pigeon.signing")

  private init(name privateLabel: String) throws {
    let publicLabel = "\(privateLabel).pub"

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
      kSecUseAuthenticationContext as String: KeyPair.context,
    ]

    var rawPublic: CFTypeRef?
    let publicStatus = SecItemCopyMatching(getPublicKey as CFDictionary, &rawPublic)
    var rawPrivate: CFTypeRef?
    let privateStatus = SecItemCopyMatching(getPrivateKey as CFDictionary, &rawPrivate)
    if
      publicStatus == errSecSuccess,
      privateStatus == errSecSuccess,
      let publicKey = rawPublic,
      let privateKey = rawPrivate
    {
      self.publicKey = publicKey as! SecKey
      self.privateKey = privateKey as! SecKey
      return
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
      kSecUseAuthenticationContext as String: KeyPair.context,
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

    publicKey = publicSec
    privateKey = privateSec
  }

  let privateKey: SecKey
  let publicKey: SecKey
}
