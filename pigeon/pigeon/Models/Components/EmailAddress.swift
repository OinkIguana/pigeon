//
//  EmailAddress.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

struct EmailAddress: Component, Identifiable, Codable {
  let id: Locator
  let emailAddress: String
}
