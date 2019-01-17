//
//  Component.swift
//  Pigeon
//
//  Created by Cameron Eldridge on 2019-01-06.
//  Copyright © 2019 Cameron Eldridge. All rights reserved.
//

import Foundation

/// A component that is associated with an entity in the entity-component-system.
///
/// TODO: consider versioned components, with a failable upward migration to allow as much inter-version communication
/// as possible (though changing components should be avoided when possible, as each is so simple there should be
/// nothing worth changing)
///
/// TODO: figure out how to store, retrieve, and manage expired components
///
/// TODO: figure out how to distribute components
protocol Component: Serializable, Deserializable {
    /// The name of this component. Must be unique as it is used to identify the component in the storage
    static var name: String { get }
}
