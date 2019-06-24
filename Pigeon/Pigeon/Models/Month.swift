//
//  Month.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

enum Month: Int, Equatable, Hashable, Codable {
  case january
  case february
  case march
  case april
  case may
  case june
  case july
  case august
  case september
  case october
  case november
  case december

  func days(in year: Int = 0) -> Int {
    switch self {
    case .january: return 31
    case .february: return year.isLeapYear ? 29 : 28
    case .march: return 31
    case .april: return 30
    case .may: return 31
    case .june: return 30
    case .july: return 31
    case .august: return 31
    case .september: return 30
    case .october: return 31
    case .november: return 30
    case .december: return 31
    }
  }
}
