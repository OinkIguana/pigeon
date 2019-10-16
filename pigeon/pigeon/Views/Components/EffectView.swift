//
//  EffectView.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-15.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import UIKit
import SwiftUI

struct EffectView: UIViewRepresentable {
  init(blur: UIBlurEffect.Style) {
    effect = UIBlurEffect(style: blur)
  }

  init(blur: UIBlurEffect.Style, vibrancy: UIVibrancyEffectStyle) {
    effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: blur), style: vibrancy)
  }

  let effect: UIVisualEffect

  func makeUIView(context: UIViewRepresentableContext<EffectView>) -> UIView {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clear

    let effectView = UIVisualEffectView(effect: effect)
    effectView.translatesAutoresizingMaskIntoConstraints = false

    view.insertSubview(effectView, at: 0)
    NSLayoutConstraint.activate([
      effectView.heightAnchor.constraint(equalTo: view.heightAnchor),
      effectView.widthAnchor.constraint(equalTo: view.widthAnchor),
    ])

    return view
  }

  func updateUIView(
    _ uiView: UIView,
    context: UIViewRepresentableContext<EffectView>) {}
}
