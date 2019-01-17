//
//  PostTitle.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-16.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

/// The title of a post
struct PostTitle: Codable, Serializable, Deserializable, Component {
    static let name: String = "PostTitle"

    let title: String
}
