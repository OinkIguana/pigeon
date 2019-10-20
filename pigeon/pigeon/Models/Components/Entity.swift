//
//  Entity.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

/// Contains some meta-info about an object within the Pigeon ecosystem. Groups of components are tied together by
/// attaching to an entity.
struct Entity: Component, Identifiable, Codable {
  let id: Locator
  /// A name identifying the type of entity this is. Applications can use this name to determine which other components
  /// the entity is expected to have.
  let prototype: String
}
