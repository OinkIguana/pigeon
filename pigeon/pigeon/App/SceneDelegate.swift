//
//  SceneDelegate.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-11.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  static var sceneHidden: Date?

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = AuthenticationViewController(
        authenticationView: { AuthenticationView() },
        contentView: { ContentView() }
      )
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  func sceneDidDisconnect(_ scene: UIScene) {}
  func sceneDidBecomeActive(_ scene: UIScene) {}
  func sceneWillResignActive(_ scene: UIScene) {}

  func sceneWillEnterForeground(_ scene: UIScene) {
    if let timeInBackground = SceneDelegate.sceneHidden.map({ -$0.timeIntervalSinceNow }) {
      if timeInBackground > Config.retrieve(Config.BackgroundAuthenticationDuration.self) {
        AuthenticationViewControllerCompanion.invalidate()
      }
    }
    SceneDelegate.sceneHidden = nil
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    SceneDelegate.sceneHidden = Date()
  }
}
