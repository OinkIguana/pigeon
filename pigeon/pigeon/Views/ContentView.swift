//
//  ContentView.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-11.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    Text("Hello World")
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(["iPhone 8", "iPhone 11", "iPad Pro (11-inch)"], id: \.self) { deviceName in
      ContentView()
        .previewDevice(PreviewDevice(rawValue: deviceName))
        .previewDisplayName(deviceName)
    }
  }
}
