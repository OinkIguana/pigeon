//
//  Networking.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-19.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import MultipeerConnectivity

/// Base networking manager, which manipulates the connection protocols at the "transport layer"-ish thing
enum Networking {
    static private let serviceName = "PigeonService"
    static fileprivate let protocolVersionKey = "species"
    static private let peerID = MCPeerID()

    static private let browserDelegate = BrowserDelegate(peerID: peerID)
    static private let advertiserDelegate = AdvertiserDelegate(peerID: peerID)

    static private let advertiser: MCNearbyServiceAdvertiser = {
        let advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: [Networking.protocolVersionKey: ProtocolVersion.alectroenasMadagascariensis.rawValue],
            serviceType: Networking.serviceName
        )
        advertiser.delegate = advertiserDelegate
        return advertiser
    }()

    static private let browser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(
            peer: peerID,
            serviceType: Networking.serviceName
        )
        browser.delegate = browserDelegate
        return browser
    }()
}

private class AdvertiserDelegate: NSObject, MCNearbyServiceAdvertiserDelegate {
    init(peerID: MCPeerID) {
        self.peerID = peerID
        super.init()
    }

    let peerID: MCPeerID

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        let requestedProtocol = context
            .flatMap { String(data: $0, encoding: .utf8) }
            .flatMap { ProtocolVersion(rawValue: $0) }

        guard let protocolVersion = requestedProtocol else { return }
        let session = MCSession(peer: self.peerID)
        session.delegate = protocolVersion.delegate

        invitationHandler(true, session)
    }
}

private class BrowserDelegate: NSObject, MCNearbyServiceBrowserDelegate {
    init(peerID: MCPeerID) {
        self.peerID = peerID
        super.init()
    }

    let peerID: MCPeerID

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let protocolVersion = info?[Networking.protocolVersionKey]?
            .data(using: .utf8)
            .flatMap { try? JSONDecoder().decode(ProtocolVersion.self, from: $0) }
            .map { min($0, ProtocolVersion.current) }
            ?? .current

        let session = MCSession(peer: self.peerID)
        session.delegate = protocolVersion.delegate

        browser.invitePeer(
            peerID,
            to: session,
            withContext: protocolVersion.rawValue.data(using: .utf8)!,
            timeout: 1
        )
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
