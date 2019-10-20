//
//  Locator.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import Foundation

struct Locator: Equatable, Hashable, Codable {
  let id: String
  /// The locator for the parent component which this component is part of. Often an Entity.
  let parent: Box<Locator>?

  private var filePath: String { "\(parent?.data.filePath ?? "/")\(id)/" }
  /// The path to the file where this component's data is stored
  var fileName: String { "\(filePath)component.pigeon" }
}
