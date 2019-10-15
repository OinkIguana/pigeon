//
//  UIViewController+Alerts.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-14.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import UIKit

extension UIViewController {
  func showAlert(title: String = L10n.Error.title, error: Error) {
    let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.ok, style: .default) { _ in alert.dismiss(animated: true) })
    present(alert, animated: true)
  }
}
