//
//  AuthenticationView.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-12.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
  @EnvironmentObject private var authenticator: Authenticator

  var body: some View {
    VStack {
      Button(action: authenticator.requestAuthentication) {
        Text(L10n.Auth.reason)
      }
    }
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(["iPhone 8", "iPhone 11", "iPad Pro (11-inch)"], id: \.self) { deviceName in
      AuthenticationView()
        .previewDevice(PreviewDevice(rawValue: deviceName))
        .previewDisplayName(deviceName)
    }
  }
}
