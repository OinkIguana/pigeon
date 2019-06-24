//
//  Birthday.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

import Foundation

struct InvalidDayOfMonth: Error {}
struct UnexpectedFutureDate: Error {}

/// A person's birthday
struct Birthday: Codable, Serializable, Deserializable, Component {
  static let version: Int64 = 1
  static let name: String = "Birthday"

  init(day: Int, month: Month, year: Int) throws {
    guard day < month.days(in: year) else {
      throw InvalidDayOfMonth()
    }
    self.day = day
    self.month = month
    self.year = year
    if date > Date() {
      throw UnexpectedFutureDate()
    }
  }

  let day: Int
  let month: Month
  let year: Int

  var date: Date {
    return DateComponents(calendar: Calendar.current, year: year, month: month.rawValue, day: day).date!
  }
}
