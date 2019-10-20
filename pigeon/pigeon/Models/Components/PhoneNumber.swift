//
//  PhoneNumber.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

struct PhoneNumber: Component, Identifiable, Codable {
  let id: Locator

  /// The raw phone number string, as provided by a user
  let string: String

  /// The pure number components
  var number: String {
    let chars = string
      .map { ch -> Character in
        if ch.isASCII {
          switch ch.uppercased().first! {
          case "A"..."C": return "2"
          case "D"..."F": return "3"
          case "G"..."I": return "4"
          case "J"..."L": return "5"
          case "M"..."O": return "6"
          case "P"..."S": return "7"
          case "T"..."V": return "8"
          case "W"..."Z": return "9"
          case "+": return "0"
          default: return ch
          }
        }
        return ch
      }
      .filter { ch in ch.isNumber }

    return String(chars)
  }
}
