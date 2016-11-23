//
//  Event.swift 
//  Stately
//
//  Created by Brian Lambert on 10/4/16.
//  See the LICENSE.md file in the project root for license information.
//

import Foundation

// Types alias for a transition tuple.
public typealias Transition = (fromState: State, toState: State)

// Event error enumeration.
public enum EventError: Error {
    case NameEmpty
    case NoTransitions
    case DuplicateTransition(fromState: State)
}

// Event class.
public class Event : Hashable {
    // The name of the event.
    public let name: String
    
    // The set of transitions for the event.
    let transitions: [Transition]
    
    /// Initializes a new instance of the Event class.
    ///
    /// - Parameters:
    ///   - name: The name of the event. Each event must have a unique name.
    ///   - transitions: The the event transitions. Each event must define at least one transition.
    public init(name nameIn: String, transitions transitionsIn: [Transition]) throws {
        // Validate the event name.
        if nameIn.isEmpty {
            throw EventError.NameEmpty
        }

        // At least one transition must be specified.
        if transitionsIn.count == 0 {
            throw EventError.NoTransitions
        }
        
        // Ensure that there are no duplicate from state transitions defined. While this wouldn't strictly
        // be a bad thing, the presence of duplicate from state transitions more than likely indicates that
        // there is a bug in the definition of the state machine, so we don't allow it.
        var fromStatesTemp = Set<State>(minimumCapacity: transitionsIn.count)
        for transition in transitionsIn {
            if fromStatesTemp.contains(transition.fromState) {
                throw EventError.DuplicateTransition(fromState: transition.fromState)
            } else {
                fromStatesTemp.insert(transition.fromState)
            }
        }
        
        // Initialize.
        name = nameIn
        transitions = transitionsIn
    }
    
    /// Returns the transition with the specified from state, if one is found; otherwise, nil.
    ///
    /// - Parameters:
    ///   - fromState: The from state.
    func transition(fromState: State) -> State? {
        // Find the transition. If it cannot be found, return nil.
        guard let transition = (transitions.first(where: { (transition: Transition) -> Bool in return transition.fromState === fromState })) else {
            return nil;
        }
        
        // Return the to state.
        return transition.toState;
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
    public static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs === rhs
    }
}
