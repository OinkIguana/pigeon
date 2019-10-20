//
//  Avatar.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import UIKit

struct Avatar: Component, Identifiable, Codable {
  let id: Locator
  let imagePath: Locator

  /// Loads the image of this Avatar
  var uiImage: UIImage? {
    // TODO: could do some image caching somewhere
    guard let data = try? Files.readData(name: imagePath.fileName) else { return nil }
    return UIImage(data: data)
  }
}
