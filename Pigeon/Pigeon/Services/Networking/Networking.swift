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
  static private let serviceName: String = "pigeon"
  static fileprivate let protocolVersionKey: String = "PigeonSpecies"
  static private let peerID = MCPeerID(displayName: "iPhone")

  static private let browserDelegate = BrowserDelegate(peerID: peerID)
  static private let advertiserDelegate = AdvertiserDelegate(peerID: peerID)

  static private let advertiser: MCNearbyServiceAdvertiser = {
    let advertiser = MCNearbyServiceAdvertiser(
      peer: peerID,
      discoveryInfo: [Networking.protocolVersionKey: ProtocolVersion.current.rawValue],
      serviceType: Networking.serviceName
    )
    advertiser.delegate = advertiserDelegate
    return advertiser
  }()

  static private let browser: MCNearbyServiceBrowser = {
    let browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Networking.serviceName)
    browser.delegate = browserDelegate
    return browser
  }()

  static func start() {
    advertiser.startAdvertisingPeer()
    browser.startBrowsingForPeers()
  }
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

    guard let protocolVersion = requestedProtocol else {
      invitationHandler(false, nil)
      return
    }

    let session = protocolVersion.delegate.createSession(myID: self.peerID, with: peerID)

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
    let protocolVersion = info?[Networking.protocolVersionKey]
      .flatMap { ProtocolVersion(rawValue: $0) }
      .map { min($0, ProtocolVersion.current) }
      ?? .current

    let delegate = protocolVersion.delegate
    if delegate.connectedTo(peer: peerID) { return } // there's already a connection here
    let session = delegate.createSession(myID: self.peerID, with: peerID)

    browser.invitePeer(
      peerID,
      to: session,
      withContext: protocolVersion.rawValue.data(using: .utf8)!,
      timeout: 30
    )
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
