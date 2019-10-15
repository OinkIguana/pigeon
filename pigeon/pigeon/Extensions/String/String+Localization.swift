//
//  String+Localization.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-12.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import Foundation

extension String {
    @inline(__always)
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: "")
    }

    func localized(comment: String = "", _ args: CVarArg...) -> String {
        return withVaList(args) {
            NSString(format: localized(comment: comment), arguments: $0) as String
        }
    }
}
