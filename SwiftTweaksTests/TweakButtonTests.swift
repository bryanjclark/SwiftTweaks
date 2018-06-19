//
//  TweakButtonTests.swift
//  SwiftTweaks
//
//  Created by Jarosław Pendowski on 30/07/2017.
//  Copyright © 2017 Khan Academy. All rights reserved.
//

import XCTest
@testable import SwiftTweaks

class TweakButtonTests: XCTestCase {
    
    func testNSCoder() {
        let originalButton = TweakButton(frame: .zero)
		originalButton.borderWidth = 3
		originalButton.cornerRadius = 5
		
		originalButton.setBorderColor(.orange, for: .normal)
		originalButton.setBorderColor(.green, for: .highlighted)
		
		let codedData = NSKeyedArchiver.archivedData(withRootObject: originalButton)
		
		guard let decodedButton = NSKeyedUnarchiver.unarchiveObject(with: codedData) as? TweakButton else {
			XCTFail()
			return
		}
		
		XCTAssertEqual(originalButton.borderWidth, decodedButton.borderWidth)
		XCTAssertEqual(originalButton.cornerRadius, decodedButton.cornerRadius)
		XCTAssertEqual(originalButton.borderColor(for: .normal)?.hexString, decodedButton.borderColor(for: .normal)?.hexString)			// has to be string, since it doesn't work well with floating points
		XCTAssertEqual(originalButton.borderColor(for: .highlighted)?.hexString, decodedButton.borderColor(for: .highlighted)?.hexString) // has to be string, since it doesn't work well with floating points
	}
    
	
}
