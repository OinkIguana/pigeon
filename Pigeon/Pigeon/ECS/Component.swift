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
/// TODO: consider versioned components
/// *   failable upward migration to allow as much inter-version as possible?
/// *   changing implementation of existing components should probably be avoided when possible, but being able to
///     migrate existing components is preferable to having legacy code lying around in later versions
///
/// TODO: figure out how to store, retrieve, and manage expired components
/// *   can components expire?
/// *   what if memory is running out, which get removed?
///
/// TODO: figure out how to distribute components
/// *   how can an entity and its components be serialized and transmitted?
///
/// TODO: consider the case of multiple components of the same type for one entity
/// *   how do these get identified, ordered, and deduped?
/// *   why not use an array inside a single component?
///
/// TODO: how to identify components
/// *   do components need identifiers (a Token on each component)?
/// *   do components a reference back to the owning entity?
/// *   handle this externally to the component (in the DB)?
protocol Component: Serializable, Deserializable {
  /// The version of this component. May be used in future
  static var version: Int64 { get }
  /// The name of this component. Must be unique as it is used to identify the component in the storage
  static var name: String { get }
}
