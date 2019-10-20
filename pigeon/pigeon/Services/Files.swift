//
//  Files.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-18.
//  Copyright © 2019 cameldridge. All rights reserved.
//

import Foundation

// MARK: - File Handle

protocol File {
  associatedtype Contents
  static var name: String { get }
}

// MARK: - File System

enum Files {
  private static func pathToFile<F: File>(_ file: F.Type) throws -> URL {
    return try pathToFile(name: F.name)
  }

  private static func pathToFile(name: String) throws -> URL {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, false)
    guard let documentsDirectory = paths.first else { throw FileSystemError.noDocumentsDirectory }
    guard let path = URL(string: documentsDirectory)?.appendingPathComponent(name) else { throw FileSystemError.invalidPath }
    return path
  }

  // MARK: JSON files

  static func writeJSON<F: File>(file: F.Type, contents: F.Contents) throws where F.Contents: Codable {
    let path = try pathToFile(file)
    let data = try JSONEncoder().encode(contents)
    try data.write(to: path, options: [.atomic])
  }

  static func readJSON<F: File>(file: F.Type) throws -> F.Contents where F.Contents: Codable {
    let path = try pathToFile(file)
    let data = try Data(contentsOf: path)
    return try JSONDecoder().decode(F.Contents.self, from: data)
  }

  // MARK: Raw files

  static func writeData<F: File>(file: F.Type, data: Data) throws where F.Contents == Data {
    let path = try pathToFile(file)
    try data.write(to: path, options: [.atomic])
  }

  static func readData<F: File>(file: F.Type) throws -> Data where F.Contents == Data {
    let path = try pathToFile(file)
    return try Data(contentsOf: path)
  }

  // MARK: AdHoc files

  static func writeData(name: String, data: Data) throws {
    let path = try pathToFile(name: name)
    try data.write(to: path, options: [.atomic])
  }

  static func readData(name: String) throws -> Data {
    let path = try pathToFile(name: name)
    return try Data(contentsOf: path)
  }
}

enum FileSystemError: Error {
  case noDocumentsDirectory
  case invalidPath
}
