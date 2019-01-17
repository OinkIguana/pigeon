//
//  Int.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

extension Int {
    var isLeapYear: Bool {
        if self % 4 != 0 { return false }
        if self % 100 != 0 { return true }
        return self % 400 == 0
    }
}
