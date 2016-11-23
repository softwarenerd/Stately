//
//  State.swift
//  Stately
//
//  Created by Brian Lambert on 10/4/16.
//  See the LICENSE.md file in the project root for license information.
//

import Foundation

// State error enumeration.
public enum StateError: Error {
    case NameEmpty
}

// Types alias for a state change tuple.
public typealias StateChange = (state: State, object: AnyObject?)

// Type alias for a state enter action.
public typealias StateEnterAction = (AnyObject?) throws -> StateChange?

// State class.
public class State: Hashable {    
    // Gets the name of the state.
    public let name: String
    
    // The optional state enter action.
    internal let stateEnterAction: StateEnterAction?

    /// Initializes a new instance of the State class.
    ///
    /// - Parameters:
    ///   - name: The name of the state. Each state must have a unique name.
    public convenience init(name nameIn: String) throws {
        try self.init(name: nameIn, stateEnterAction: nil)
    }

    /// Initializes a new instance of the State class.
    ///
    /// - Parameters:
    ///   - name: The name of the state. Each state must have a unique name.
    ///   - stateEnterAction: The state enter action.
    public convenience init(name nameIn: String, stateEnterAction stateEnterActionIn: @escaping StateEnterAction) throws {
        try self.init(name: nameIn, stateEnterAction: StateEnterAction?(stateEnterActionIn))
    }
    
    /// Initializes a new instance of the State class.
    ///
    /// - Parameters:
    ///   - name: The name of the state. Each state must have a unique name.
    ///   - stateAction: The optional state enter action.
    private init(name nameIn: String, stateEnterAction stateEnterActionIn: StateEnterAction?) throws {
        // Validate the state name.
        if nameIn.isEmpty {
            throw StateError.NameEmpty
        }
        
        // Initialize.
        name = nameIn
        stateEnterAction = stateEnterActionIn
    }

    /// Gets the hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        get {
            return name.hashValue
        }
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: State, rhs: State) -> Bool {
        return  lhs === rhs
    }
}
