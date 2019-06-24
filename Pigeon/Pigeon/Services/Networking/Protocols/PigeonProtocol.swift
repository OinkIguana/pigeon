//
//  PigeonProtocol.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import MultipeerConnectivity

/// The structure of a message that can be sent.
///
/// TODO: find a way to implement this so that it can follow a versioning system similar to the protocols
struct PigeonMessage: Codable {}

/// Common requirements of implementors of the Pigeon Protocol.
///
/// The Pigeon Protocol aims to be an application layer protocol. As it may undergo revisions, it is important to ensure
/// that the implementations of each revision remain compatible.
protocol PigeonProtocol: MCSessionDelegate {
  /// The data serializer for this protocol
  static var serializer: Serializer { get }
  /// The data deserializer for this protocol
  static var deserializer: Deserializer { get }
  /// The protocol version identifier
  static var version: ProtocolVersion { get }

  /// Creates a session object that is compatible with this protocol version. It is expected that the delegate is
  /// already attached to the returned session.
  func createSession(myID: MCPeerID, with peer: MCPeerID) -> MCSession

  /// Checks if there is currently a connection to a peer with this ID
  func connectedTo(peer: MCPeerID) -> Bool
}

/// Protocol version identifiers. Until they run out (they probably won't), we can take names from the [list of pigeon
/// species on Wikipedia](https://en.wikipedia.org/wiki/List_of_Columbidae_species)
///
/// Note that they must be taken alphabetically so that the ordering remains consistent
enum ProtocolVersion: String, Comparable, Equatable, Codable, CaseIterable {
  case alectroenasMadagascariensis = "Alectroenas Madagascariensis"

  /// The most recent protocol version
  static var current: ProtocolVersion { return .alectroenasMadagascariensis }

  /// Creates a MCSessionDelegate that implements this version of the protocol. Sadly, this is a very manual deduction
  var delegate: PigeonProtocol {
    switch self {
    case .alectroenasMadagascariensis: return AlectroenasMadagascariensis.instance
    }
  }

  static func < (lhs: ProtocolVersion, rhs: ProtocolVersion) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}
