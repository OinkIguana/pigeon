//
//  WelcomeViewController.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2018-12-18.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WelcomeViewController: PigeonViewController {
    @IBOutlet weak var pigeonImageView: UIImageView!
    @IBOutlet weak var pigeonCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Networking.start() // TODO: move this line
        entryAnimation()
        handleNameForm()
    }
}

// MARK: - UI

extension WelcomeViewController {
    fileprivate func entryAnimation() {
        pigeonCenterConstraint.isActive = false
        pigeonImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        UIView.animate(
            withDuration: 0.6,
            delay: 0.5,
            options: [UIView.AnimationOptions.curveEaseInOut],
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }

    fileprivate func handleNameForm() {
        let name = nameField.rx.text
            .map { $0 ?? "" }

        name.map { !$0.isEmpty }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

        nextButton.rx.tap
            .withLatestFrom(name)
            .subscribe(onNext: { [weak self] name in
                
            })
            .disposed(by: disposeBag)
    }
}
