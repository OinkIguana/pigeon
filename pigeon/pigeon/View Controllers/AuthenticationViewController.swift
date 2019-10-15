//
//  AuthenticationViewController.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-13.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import LocalAuthentication

// MARK: - Authenticator

class Authenticator: ObservableObject {
  fileprivate init(delegate: AuthenticatorDelegate) {
    self.delegate = delegate
  }

  private weak var delegate: AuthenticatorDelegate?
  func requestAuthentication() { delegate?.requestAuthentication() }
}

fileprivate protocol AuthenticatorDelegate: AnyObject {
  func requestAuthentication()
}

// MARK: - Authentication View Controller

class AuthenticationViewController<AView, CView>: UIHostingController<CView>
where AView: View, CView: View {
  private var authenticationView: AView!

  private let localAuthentication: LAContext? = {
    let context = LAContext()
    context.localizedCancelTitle = L10n.Auth.cancel

    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return nil }
    return context
  }()

  private var authenticated = CurrentValueSubject<Bool, Never>(false)
  private var authenticationModal: UIViewController?

  private var subscriptions: Set<AnyCancellable> = []

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    authenticated
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] authenticated in
        if !authenticated && self.authenticationModal == nil {
          let controller = UIHostingController(rootView: self.authenticationView.environmentObject(Authenticator(delegate: self)))
          controller.isModalInPresentation = true
          self.present(controller, animated: true)
          self.authenticationModal = controller
        } else if authenticated, let modal = self.authenticationModal {
          modal.dismiss(animated: true)
        }
      }
      .store(in: &subscriptions)
  }
}

// MARK: - AuthenticatorDelegate

extension AuthenticationViewController: AuthenticatorDelegate {
  fileprivate func requestAuthentication() {
    localAuthentication?.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: L10n.Auth.reason) { success, error in
      self.authenticated.send(success)
      if !success, let error = error as? LAError {
        switch error.code {
        // these errors should not be displayed to the user as an error
        case .userCancel,
             .userFallback,
             .systemCancel: return
        default: break
        }
      }
      error.map { self.showAlert(error: $0) }
    }
  }
}

// MARK: - Methods

extension AuthenticationViewController {
  func invalidate() {
    self.authenticated.send(false)
  }
}

// MARK: - Navigation

extension AuthenticationViewController {
  convenience init (@ViewBuilder authenticationView: () -> AView, @ViewBuilder contentView: () -> CView) {
    self.init(rootView: contentView())
    self.authenticationView = authenticationView()
  }
}
