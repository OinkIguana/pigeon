//
//  Box.swift
//  pigeon
//
//  Created by Cameron Eldridge on 2019-10-12.
//  Copyright © 2019 cameldridge. All rights reserved.
//

/// A Box wraps any type to guarantee that the contents are not a top level primitive, which enables encoding them
/// correctly as JSON.
struct Box<T: Codable>: Codable { let v: T }
