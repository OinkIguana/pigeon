//
//  AlectroenasMadagascariensis.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import MultipeerConnectivity
import RxSwift

private struct IncorrectDecryptionError: Error {}
private struct HandshakeError: Error { let reason: Error }

private struct Challenge: Codable, Equatable {
    init() throws { data = try Data.secureRandom(bytes: 32) }
    let data: Data
}

/// Everything transmitted is wrapped in this Packet type, which ensures encryption and validation of all data
/// sent and received.
private struct Packet: Codable, Serializable, Deserializable {
    let sender = Token.mine
    let receiver: Token
    let data: Compressed<Signed<Encrypted<PigeonMessage>>>
}

/// Wraps the MCSession to ensure the handshake is performed correctly and
private struct Session {
    init(session: MCSession, id: MCPeerID, with peer: MCPeerID) {
        self.session = session
        self.id = id
        self.peer = peer
        self.state = .claim
    }

    /// The other peer's token, only available after completing the handshake
    var token: Token?
    /// This device's peer ID
    let id: MCPeerID
    /// The other device's peer ID
    let peer: MCPeerID
    /// The underlying session
    let session: MCSession

    /// Current step of the handshake
    private enum State {
        case claim
        case challenge(Challenge, Claims)
        case response(Challenge, Claims)
        case connected
    }
    private var state: State

    func send<T: Serializable>(_ data: T) throws {
        try session.send(try AlectroenasMadagascariensis.serializer.serialize(data), toPeers: [peer], with: .reliable)
    }

    /// Begin the handshake process
    func authenticate() throws {
        try send(Claims.mine)
    }

    /// Steps through the handshake protocol, then continues to deserialize packets as they arrive
    ///
    /// Handshake Protocol:
    /// 1.  (A) Send over your claims
    /// 2.  (B) Receive claims, and decide whether to trust them
    ///
    ///     If the associated token has already been fully verified, it can be fully trusted by the end. If not, then
    ///     they should only be tentatively trusted
    /// 3.  (B) Send a challenge (random data), encrypted with the claimed encryption key
    /// 4.  (A) Decrypt the received challenge, sign the plaintext, and send it back
    /// 5.  (B) If the plaintext challenge and signature are correct, accept the claims
    ///
    /// Both clients must perform the same handshake in lockstep, resulting in both sides trusting each other
    mutating func receive(data: Data) throws -> Packet? {
        switch state {
        case .claim:
            do {
                let claims = try AlectroenasMadagascariensis.deserializer.deserialize(Claims.self, from: data)
                try KeyManager.process(claims: claims)
                // attempt to use the verified verification key for this user
                // ensure that their encryptionKey gets decoded successfully
                let encryptionKey = try claims.encryptionKey.verify(using: claims.verificationKey)

                // generate a random challenge, which they must decrypt, sign, and return
                let challenge = try Challenge()
                let encrypted: Encrypted<Challenge> = try Encrypted(challenge, using: encryptionKey)
                try send(encrypted)
                state = .challenge(challenge, claims)
            } catch let error {
                throw HandshakeError(reason: error)
            }
        case let .challenge(challenge, claims):
            do {
                let encrypted = try AlectroenasMadagascariensis.deserializer.deserialize(Encrypted<Challenge>.self, from: data)
                let decrypted = try encrypted.decrypt()
                let signed: Signed<Challenge> = try Signed(decrypted)
                try send(signed)
                state = .response(challenge, claims)
            } catch let error {
                throw HandshakeError(reason: error)
            }
        case let .response(challenge, claims):
            do {
                // check the response for correct signature and decryption. If it's good, then we got the real guy
                let signedResponse = try AlectroenasMadagascariensis.deserializer.deserialize(Signed<Challenge>.self, from: data)
                let response = try signedResponse.verify(using: claims.verificationKey)
                if challenge == response {
                    try KeyManager.insert(claims.token, encryptionKey: claims.encryptionKey)
                    token = claims.token
                    state = .connected
                } else {
                    throw IncorrectDecryptionError()
                }
            } catch let error {
                throw HandshakeError(reason: error)
            }
        case .connected:
            return try AlectroenasMadagascariensis.deserializer.deserialize(Packet.self, from: data)
        }
        return nil
    }
}

/// First implementation of the Pigeon protocol.
class AlectroenasMadagascariensis: NSObject {
    override private init() {}
    /// Singleton instance
    static let instance = AlectroenasMadagascariensis()

    /// Currently active sessions, by PeerID
    private var peers: [MCPeerID: Session] = [:]
    /// All received packets are pushed here to be handled by a central process
    private let packets = PublishSubject<Packet>()

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting: break
        case .connected:
            do {
                try peers[peerID]?.authenticate()
            } catch {
                session.disconnect()
                peers.removeValue(forKey: peerID)
            }
        case .notConnected:
            session.disconnect()
            peers.removeValue(forKey: peerID)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            if let packet = try peers[peerID]?.receive(data: data) {
                packets.onNext(packet)
            }
        } catch let error as HandshakeError {
            print("Handshake failed: \(error)")
            session.disconnect()
            peers.removeValue(forKey: peerID)
        } catch {
            // these are just some bad data being received, so let's ignore it
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // unimplemented
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // unimplemented
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // unimplemented
    }
}

extension AlectroenasMadagascariensis: PigeonProtocol {
    static var version: ProtocolVersion { return .alectroenasMadagascariensis }
    static var serializer: Serializer { return JSONEncoder() }
    static var deserializer: Deserializer { return JSONDecoder() }

    func createSession(myID: MCPeerID, with peer: MCPeerID) -> MCSession {
        let session = MCSession(peer: myID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        peers[peer] = Session(session: session, id: myID, with: peer)
        return session
    }

    func connectedTo(peer: MCPeerID) -> Bool {
        return peers[peer] != nil
    }
}
