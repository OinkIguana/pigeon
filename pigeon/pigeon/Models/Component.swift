//
//  Component.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

protocol Component: Identifiable {
  var version: Int { get }
}

extension Component {
  var version: Int { 0 }
}
