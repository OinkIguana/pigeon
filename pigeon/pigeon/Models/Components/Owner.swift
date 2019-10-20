//
//  Owner.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-19.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import Foundation

/// Describes the owner of an entity. That is, the person/device who the entity is attributed to.
/// The owner gets to make all decisions relating to the sharing and contents of the entity.
struct Owner: Component, Identifiable, Codable {
  let id: Locator
  let owner: Data
}
