//
//  Binding+Transforms.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-13.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import SwiftUI

extension Binding {
  /// The const binding cannot be set.
  var const: Self {
    Binding(
      get: { self.wrappedValue },
      set: { value in }
    )
  }
}

extension Binding where Value == Bool {
  /// The ! operator inverts the value of a binding
  static prefix func ! (binding: Binding<Bool>) -> Binding<Bool> {
    Binding(
      get: { !binding.wrappedValue },
      set: { value in binding.wrappedValue = !value }
    )
  }
}
