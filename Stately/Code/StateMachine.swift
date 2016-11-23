//
//  StateMachine.swift
//  Stately
//
//  Created by Brian Lambert on 10/4/16.
//  See the LICENSE.md file in the project root for license information.
//

import Foundation

// State machine error enumeration.
public enum StateMachineError: Error {
    case NoStatesDefined
    case DefaultStateUndefined
    case DuplicateStateDefinition(state: State)
    case DuplicateStateNameDefinition(name: String)
    case NoEventsDefined
    case DuplicateEventDefinition(event: Event)
    case DuplicateEventNameDefinition(name: String)
    case TransitionFromStateNotDefined(fromState: State)
    case TransitionToStateNotDefined(toState: State)
    case UndefiendEventFired
    case UndefiendState(state: State)
    case NoTransitionFromCurrentStateFound(currentState: State)
}

// StateMachine class.
public class StateMachine {
    // The name of the state machine.
    public let name: String
    
    // The states that are defined in the state machine.
    private let states: Set<State>

    // The events that are defined in the state machine.
    private let events: Set<Event>
    
    // The serial dispatch queue used to synchronize access to the state machine.
    private let serialDispatchQueue: DispatchQueue
    
    // The state.
    private var state: State
    
    /// Initializes a new instance of the StateMachine class.
    ///
    /// - Parameters:
    ///   - name: The name of the state machine.
    ///   - defaultState: The default state. This state must be one of the states supplied in the states array.
    ///   - states: An array of states that the state machine can be in.
    ///   - events: An array of events that can be fired on the state machine.
    public init(name nameIn: String, defaultState: State, states statesIn: [State], events eventsIn: [Event]) throws {
        // Ensure that at least one state is defined.
        if statesIn.count == 0 {
            throw StateMachineError.NoStatesDefined
        }

        // Ensure that at least one event is defined.
        if eventsIn.count == 0 {
            throw StateMachineError.NoEventsDefined
        }

        // Construct the set of states.
        var statesNameDictionaryTemp = Dictionary<String, State>(minimumCapacity: statesIn.count)
        var statesTemp = Set<State>(minimumCapacity: statesIn.count)
        for state in statesIn {
            // Ensure that this isn't a duplicate state.
            if statesTemp.contains(state) {
                throw StateMachineError.DuplicateStateDefinition(state: state)
            } else if statesNameDictionaryTemp[state.name] != nil {
                throw StateMachineError.DuplicateStateNameDefinition(name: state.name)
            } else {
                // Insert the state.
                statesNameDictionaryTemp[state.name] = state
                statesTemp.insert(state)
            }
        }

        // Construct the set of events.
        var eventsNameDictionaryTemp = Dictionary<String, Event>(minimumCapacity: statesIn.count)
        var eventsTemp = Set<Event>(minimumCapacity: eventsIn.count)
        for event in eventsIn {
            // Ensure that this isn't a duplicate event.
            if eventsTemp.contains(event) {
                throw StateMachineError.DuplicateEventDefinition(event: event)
            } else if eventsNameDictionaryTemp[event.name] != nil {
                throw StateMachineError.DuplicateEventNameDefinition(name: event.name)
            } else {
                // Validate the transitions for the event.
                for transition in event.transitions {
                    // Ensure that the from state is defined.
                    if !statesTemp.contains(transition.fromState) {
                        throw StateMachineError.TransitionFromStateNotDefined(fromState: transition.fromState)
                    }
                    
                    // Ensure that the to state is defined.
                    if !statesTemp.contains(transition.toState) {
                        throw StateMachineError.TransitionToStateNotDefined(toState: transition.toState)
                    }
                }

                // Insert the event.
                eventsNameDictionaryTemp[event.name] = event;
                eventsTemp.insert(event)
            }
        }
        
        // Ensure that the default state is defined in the set of states.
        if !statesTemp.contains(defaultState) {
            throw StateMachineError.DefaultStateUndefined
        }

        // All checks have been performed and the state machine appears to be valid. Initialize members.
        serialDispatchQueue = DispatchQueue(label: "StatelyStateMachineTimeout:\(nameIn)")
        name = nameIn
        states = statesTemp
        events = eventsTemp
        state = try State(name: "[None]")
        try changeState(stateChange: StateChange(defaultState, nil))
    }
    
    /// Fires an event.
    ///
    /// - Parameters:
    ///   - event: The event to fire.
    public func fireEvent(event: Event) throws {
        try fireEvent(event: event, object: nil)
    }

    /// Fires an event.
    ///
    /// - Parameters:
    ///   - event: The event to fire.
    ///   - object: An optional object which represents additional information for the event.
    public func fireEvent(event: Event, object: AnyObject?) throws {
        // Ensure that the event is defined in the state machine.
        guard events.contains(event) else {
            throw StateMachineError.UndefiendEventFired
        }

        // Fire the event.
        try serialDispatchQueue.sync {
            // Obtain the state to transition to.
            guard let toState = event.transition(fromState: state) else {
                throw StateMachineError.NoTransitionFromCurrentStateFound(currentState: state)
            }
            
            // Change state.
            try changeState(stateChange: StateChange(toState, object))
        }
    }
    
    /// Changes state.
    ///
    /// - Parameters:
    ///   - stateChange: A tuple representing the state change.
    private func changeState(stateChange stateChangeIn: StateChange) throws {
        // Perform the state change, if it's changing.
        var stateChange = stateChangeIn
        while stateChange.state != state {
            // Set the new state.
            state = stateChange.state
            
            // If there's no state enter action for the new state, we're done. If there is a state enter action, perform it and,
            // if it doesn't result in an immediate state change, we're done.
            guard let stateEnterAction = state.stateEnterAction, let immediateStateChange = try stateEnterAction(stateChange.object) else {
                break
            }
            
            // Check that the immediate state change's state is defined in the state machine.
            guard states.contains(immediateStateChange.state) else {
                throw StateMachineError.UndefiendState(state: immediateStateChange.state)
            }
            
            // Set-up the immediate state change for the next loop iteration.
            stateChange = immediateStateChange
        }
    }
}
