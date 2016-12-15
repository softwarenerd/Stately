//
//  Event.swift 
//  Stately
//
//  Created by Brian Lambert on 10/4/16.
//  See the LICENSE.md file in the project root for license information.
//

import Foundation

// Types alias for a transition tuple.
public typealias Transition = (fromState: State?, toState: State)

// Event error enumeration.
public enum EventError: Error {
    case NameEmpty
    case NoTransitions
    case DuplicateTransition(fromState: State)
    case MultipleWildcardTransitions
}

// Event class.
public class Event : Hashable {
    // The name of the event.
    public let name: String
    
    // The set of transitions for the event.
    let transitions: [Transition]
    
    // The wildcard transition.
    let wildcardTransition: Transition?
    
    /// Initializes a new instance of the Event class.
    ///
    /// - Parameters:
    ///   - name: The name of the event. Each event must have a unique name.
    ///   - transitions: The transitions for the event. An event must define at least one transition.
    ///     A transition with a from state of nil is the wildcard transition and will match any from
    ///     state. Only one wildcard transition may defined for an event.
    public init(name nameIn: String, transitions transitionsIn: [Transition]) throws {
        // Validate the event name.
        if nameIn.isEmpty {
            throw EventError.NameEmpty
        }

        // At least one transition must be specified.
        if transitionsIn.count == 0 {
            throw EventError.NoTransitions
        }
        
        // Ensure that there are no duplicate from state transitions defined. (While this wouldn't strictly
        // be a bad thing, the presence of duplicate from state transitions more than likely indicates that
        // there is a bug in the definition of the state machine, so we don't allow it.) Also, there can be
        // only one wildcard transition (a transition with a nil from state) defined.
        var wildcardTransitionTemp: Transition? = nil
        var fromStatesTemp = Set<State>(minimumCapacity: transitionsIn.count)
        for transition in transitionsIn {
            // See if there's a from state. If there is, ensure it's not a duplicate. If there isn't, then
            // ensure there is only one wildcard transition.
            if let fromState = transition.fromState {
                if fromStatesTemp.contains(fromState) {
                    throw EventError.DuplicateTransition(fromState: fromState)
                } else {
                    fromStatesTemp.insert(fromState)
                }
            } else {
                if wildcardTransitionTemp != nil {
                    throw EventError.MultipleWildcardTransitions
                } else {
                    wildcardTransitionTemp = transition
                }
            }
        }
        
        // Initialize.
        name = nameIn
        transitions = transitionsIn
        wildcardTransition = wildcardTransitionTemp
    }
    
    /// Returns the transition with the specified from state, if one is found; otherwise, nil.
    ///
    /// - Parameters:
    ///   - fromState: The from state.
    func transition(fromState: State) -> State? {
        // Find the transition. If it cannot be found, and there's a wildcard transition, return its to state.
        // Otherwise, nil will be returned.
        guard let transition = (transitions.first(where: { (transition: Transition) -> Bool in return transition.fromState === fromState })) else {
            return wildcardTransition?.toState
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
