//
//  StatelyTests.swift
//  StatelyTests
//
//  Created by Brian Lambert on 10/4/16.
//  See the LICENSE.md file in the project root for license information.
//

import XCTest
@testable import Stately

// StatelyTests class.
class StatelyTests: XCTestCase
{
    // Sets up the test. This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
    }
    
    // Tears down the test. This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }
    
    // Test no states defined.
    func testNoStatesDefined() {
        do {
            // Setup.
            let stateA = try State(name: "A")
            let event1 = try Event(name: "1", transitions: [(fromState: stateA, toState: stateA)])

            // Test.
            let _ = try StateMachine(name: "StateMachine", defaultState: stateA, states: [], events: [event1])
            
            // Assert.
            XCTFail("No error thrown.")
        } catch StateMachineError.NoStatesDefined {
            // Expect to arrive here. This is success.
        } catch {
            // Assert.
            XCTFail("Wrong error thrown: \(error)")
        }
    }

    // Test no events defined.
    func testNoEventsDefined() {
        do {
            // Setup.
            let stateA = try State(name: "A")

            // Test.
            let _ = try StateMachine(name: "StateMachine", defaultState: stateA, states: [stateA], events: [])
            
            // Assert.
            XCTFail("No error thrown.")
        } catch StateMachineError.NoEventsDefined {
            // Expect to arrive here. This is success.
        } catch {
            // Assert.
            XCTFail("Wrong error thrown: \(error)")
        }
    }

    // Tests duplicate state definition.
    func testDuplicateStateDefinition() {
        do {
            // Setup.
            let stateA = try State(name: "A")
            let event1 = try Event(name: "1", transitions: [(fromState: stateA, toState: stateA)])

            // Test.
            let _ = try StateMachine(name: "StateMachine", defaultState: stateA, states: [stateA, stateA], events: [event1])
            
            // Assert.
            XCTFail("No error thrown.")
        } catch StateMachineError.DuplicateStateDefinition {
            // Expect to arrive here. This is success.
        } catch {
            // Assert.
            XCTFail("Wrong error thrown: \(error)")
        }
    }

    // Tests duplicate state name definition.
    func testDuplicateStateNameDefinition() {
        do {
            // Setup.
            let stateA = try State(name: "A")
            let stateB = try State(name: "A")
            let event1 = try Event(name: "1", transitions: [(fromState: stateA, toState: stateB)])

            // Test.
            let _ = try StateMachine(name: "StateMachine", defaultState: stateA, states: [stateA, stateB], events: [event1])

            // Assert.
            XCTFail("No error thrown.")
        } catch StateMachineError.DuplicateStateNameDefinition {
            // Expect to arrive here. This is success.
        } catch {
            // Assert.
            XCTFail("Wrong error thrown: \(error)")
        }
    }

    // Tests a valid state transition.
    func testValidStateTransition() {
        do {
            // Setup.
            let stateA = try State(name: "A")
            let stateB = try State(name: "B")
            let event1 = try Event(name: "1", transitions: [(fromState: stateA, toState: stateB)])
            let event2 = try Event(name: "2", transitions: [(fromState: stateB, toState: stateA)])

            // Test.
            let stateMachine = try StateMachine(name: "StateMachine", defaultState: stateA, states: [stateA, stateB], events: [event1, event2])
            try stateMachine.fireEvent(event: event1)
            
            // Expect to arrive here. This is success.
        } catch {
            // Assert.
            XCTFail("An error was thrown: \(error)")
        }
    }

    // Tests an invalid state transition.
    func testInvalidStateTransition() {
        do {
            // Setup.
            let stateA = try State(name: "A")
            let stateB = try State(name: "B")
            let event1 = try Event(name: "1", transitions: [(fromState: stateA, toState: stateB)])
            let event2 = try Event(name: "2", transitions: [(fromState: stateB, toState: stateA)])

            // Test.
            let stateMachine = try StateMachine(name: "StateMachine", defaultState: stateA, states: [stateA, stateB], events: [event1, event2])
            try stateMachine.fireEvent(event: event2)

            // Assert.
            XCTFail("No error thrown.")
        } catch StateMachineError.NoTransitionFromCurrentStateFound {
            // Expect to arrive here. This is success.
        } catch {
            // Assert.
            XCTFail("Wrong error thrown: \(error)")
        }
    }
    
    // Tests enter actions.
    func testEnterActions() {
        do {
            // Setup.
            var stateAEntered = false
            let stateA = try State(name: "A") { (object: AnyObject?) -> StateChange? in
                stateAEntered = true
                return nil
            }
            var stateBEntered = false
            let stateB = try State(name: "B") { (object: AnyObject?) -> StateChange? in
                stateBEntered = true
                return nil
            }
            let event1 = try Event(name: "1", transitions: [(fromState: stateA, toState: stateB)])
            let event2 = try Event(name: "2", transitions: [(fromState: stateB, toState: stateA)])

            // Test.
            let stateMachine = try StateMachine(name: "StateMachine", defaultState: stateA, states: [stateA, stateB], events: [event1, event2])
            try stateMachine.fireEvent(event: event1)
            try stateMachine.fireEvent(event: event2)
            
            // Assert.
            XCTAssertTrue(stateAEntered)
            XCTAssertTrue(stateBEntered)
        }
        catch {
            // Assert.
            XCTFail("Unexpeced error thrown: \(error)")
        }
    }

    // Tests enter actions with an immediate state transition.
    func testEnterActionsWithImmediateStateTransition() {
        do {
            // Setup.
            var stateAEntered = false
            let stateA = try State(name: "A") { (object: AnyObject?) -> StateChange? in
                stateAEntered = true
                return nil
            }
            var stateBEntered = false
            let stateB = try State(name: "B") { (object: AnyObject?) -> StateChange? in
                stateBEntered = true
                return nil
            }
            var stateCEntered = false
            let stateC = try State(name: "C") { (object: AnyObject?) -> StateChange? in
                stateCEntered = true
                return StateChange(stateB, nil)
            }
            let event1 = try Event(name: "1", transitions: [(fromState: stateA, toState: stateC)])
            let event2 = try Event(name: "2", transitions: [(fromState: stateB, toState: stateA)])

            // Test.
            let stateMachine = try StateMachine(name: "StateMachine", defaultState: stateA, states: [stateA, stateB, stateC], events: [event1, event2])
            try stateMachine.fireEvent(event: event1)
            try stateMachine.fireEvent(event: event2)

            // Assert.
            XCTAssertTrue(stateAEntered)
            XCTAssertTrue(stateBEntered)
            XCTAssertTrue(stateCEntered)
        } catch {
            // Assert.
            XCTFail("Unexpeced error thrown: \(error)")
        }
    }
    
    // Tests multiple threads.
    func testMultipleThreads() {
        do {
            // Setup.
            var stateTransitionCount = 0
            let serialDispatchQueue = DispatchQueue(label: "StatelyTestMultipleThreads")
            let stateAction = { (object: AnyObject?) -> StateChange? in
                serialDispatchQueue.sync {
                    stateTransitionCount += 1
                }
                
                return nil
            }
            let stateA = try State(name: "A", stateEnterAction: stateAction)
            let stateB = try State(name: "B", stateEnterAction: stateAction)
            let event1 = try Event(name: "1", transitions: [(fromState: stateA, toState: stateB), (fromState: stateB, toState: stateA)])
            let stateMachine = try StateMachine(name: "StateMachine", defaultState: stateA, states: [stateA, stateB], events: [event1])
            
            // Test.
            let concurrentDispatchQueue = DispatchQueue(label: "StatelyTestMultipleThreadsTesters", attributes: .concurrent)
            var dispatchWorkItems = [DispatchWorkItem]()
            for _ in 0...99 {
                let dispatchWorkItem = DispatchWorkItem {
                    for _ in 0...99 {
                        do {
                            try stateMachine.fireEvent(event: event1)
                        } catch {
                            XCTFail("Unexpeced error thrown: \(error)")
                        }
                    }
                }
                dispatchWorkItems.append(dispatchWorkItem)
                concurrentDispatchQueue.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: dispatchWorkItem)
            }
            
            // Wait for testers to be done.
            for dispatchWorkItem in dispatchWorkItems {
                dispatchWorkItem.wait()
            }
            
            // Assert.
            XCTAssertTrue(stateTransitionCount == 10001)
        } catch {
            // Assert.
            XCTFail("Unexpeced error thrown: \(error)")
        }
    }
}
