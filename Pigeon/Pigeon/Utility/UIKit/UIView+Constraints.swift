//
//  UIView+Constraints.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-05.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

import UIKit

extension UIView {
  func constrainable() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
}
