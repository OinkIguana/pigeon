//
//  Storage.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Strongbox

protocol SecureStorable: Codable {
    static var storageKey: String { get }
}

class StorageFailedError: Error {}

enum Storage {
    private static let keychain = Strongbox()

    static func store<Item: SecureStorable>(_ item: Item) throws {
        let data = try JSONEncoder().encode(item)
        guard keychain.archive(data as NSData, key: Item.storageKey) else {
            throw StorageFailedError()
        }
    }

    static func retrieve<Item: SecureStorable>() throws -> Item? {
        guard let data = keychain.unarchive(objectForKey: Item.storageKey) as? NSData else {
            return nil
        }
        return try JSONDecoder().decode(Item.self, from: data as Data)
    }
}
