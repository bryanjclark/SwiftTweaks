//
//  TweakActionTests.swift
//  SwiftTweaks
//
//  Created by Jarosław Pendowski on 28/04/2017.
//  Copyright © 2017 Khan Academy. All rights reserved.
//

import XCTest
@testable import SwiftTweaks

class TweakActionTests: XCTestCase {
	
	var tweak: Tweak<TweakAction>!
    
    override func setUp() {
        super.setUp()
		
		tweak = Tweak<TweakAction>("", "", "")
    }
    
    override func tearDown() {
        super.tearDown()
		
		tweak = nil
    }
	
	func testEmpty() {
		// should just not crash
		executeTweak()
	}
	
	func testAddingCallback() {
		var executed = false
		tweak.addClosure {
			executed = true
		}
		// shouldn't be executed after just adding
		XCTAssertFalse(executed)
		
		executeTweak()
		
		XCTAssertTrue(executed)
	}
	
	func testOrder() {
		var order: [Int] = []
		
		tweak.addClosure {
			order.append(0)
		}
		tweak.addClosure {
			order.append(1)
		}
		tweak.addClosure {
			order.append(2)
		}
		
		XCTAssertEqual(order, [])
		
		executeTweak()
		
		XCTAssertEqual(order, [0, 1, 2])
	}
	
	func testMultipleExecutions() {
		var order: [Int] = []
		
		tweak.addClosure {
			order.append(0)
		}
		tweak.addClosure {
			order.append(1)
		}
		tweak.addClosure {
			order.append(2)
		}
		
		XCTAssertEqual(order, [])
		
		executeTweak()
		
		XCTAssertEqual(order, [0, 1, 2])
		
		executeTweak()
		
		XCTAssertEqual(order, [0, 1, 2, 0, 1, 2])
		
		executeTweak()
		
		XCTAssertEqual(order, [0, 1, 2, 0, 1, 2, 0, 1, 2])
	}
	
	func testRemovingCallback() {
		var order: [Int] = []
		
		tweak.addClosure {
			order.append(0)
		}
		let identifier = tweak.addClosure {
			order.append(1)
		}
		tweak.addClosure {
			order.append(2)
		}
		
		XCTAssertEqual(order, [])
		
		executeTweak()
		
		XCTAssertEqual(order, [0, 1, 2])
		
		_ = try? tweak.removeClosure(with: identifier)
		
		executeTweak()

		XCTAssertEqual(order, [0, 1, 2, 0, 2])
	}
	
	func testRemovingNonExisting() {
		do {
			try tweak.removeClosure(with: 42)
			XCTFail("Should threw at nonexisting identifier")
		} catch { }
	}
	
	private func executeTweak() {
		tweak.defaultValue.evaluateAllClosures()
	}
}
