//
//  Website.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import Foundation

struct Website: Component, Identifiable, Codable {
  let id: Locator
  let title: String
  let url: URL
}
