//
//  AlectroenasMadagascariensis.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import MultipeerConnectivity
import RxSwift

/// Original draft of the Pigeon protocol.
class AlectroenasMadagascariensis: NSObject, PigeonProtocol {
    static var version: ProtocolVersion = .alectroenasMadagascariensis

    struct Message: Codable {
        struct Body: Codable {
            let schema: String
            let data: Data
        }

        let sender: Token
        let receiver: Token
        let data: Signed<Encrypted<Body>>
    }

    var peers: [MCPeerID: MCSession] = [:]
    let messages = PublishSubject<Message>()

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting: break
        case .connected:
            peers[peerID] = session
        case .notConnected:
            session.disconnect()
            peers.removeValue(forKey: peerID)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONDecoder().decode(Message.self, from: data)
            messages.onNext(message)
        } catch {
            // invalid data received... just discard it for now
            // maybe ping back to the other guy that it was not received correctly?
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
