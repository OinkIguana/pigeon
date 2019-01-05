//
//  Compressed.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-20.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import Foundation
import Gzip

/// A wrapper type that compresses data, requiring it to be uncompressed before use.
struct Compressed<T: Codable>: Codable {
    init(from decoder: Decoder) throws {
        data = try decoder.singleValueContainer().decode(Data.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    init(_ item: T) throws {
        let fullData = try JSONEncoder().encode(item)
        data = try fullData.gzipped(level: .bestCompression)
    }

    private let data: Data

    func decompress() throws -> Data {
        return try data.gunzipped()
    }
}
