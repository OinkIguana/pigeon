//
//  PigeonProtocol.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import MultipeerConnectivity

/// Application layer backwards compatible protocol
protocol PigeonProtocol: MCSessionDelegate {
    /// The protocol version identifier
    static var version: ProtocolVersion { get }
}

/// Protocol version identifiers. Until they run out (they probably won't), we can take names from the [list of pigeon
/// species on Wikipedia](https://en.wikipedia.org/wiki/List_of_Columbidae_species)
///
/// Note that they must be taken alphabetically so that the ordering remains consistent
enum ProtocolVersion: String, Comparable, Equatable, Codable {
    case alectroenasMadagascariensis

    /// The most recent protocol version
    static var current: ProtocolVersion { return .alectroenasMadagascariensis }

    /// Creates a MCSessionDelegate that implements this version of the protocol. Sadly, this is a very manual deduction
    var delegate: PigeonProtocol {
        switch self {
        case .alectroenasMadagascariensis: return AlectroenasMadagascariensis()
        }
    }

    static func < (lhs: ProtocolVersion, rhs: ProtocolVersion) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
