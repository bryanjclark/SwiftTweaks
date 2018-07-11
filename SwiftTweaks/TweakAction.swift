//
//  TweakAction.swift
//  SwiftTweaks
//
//  Created by Jarosław Pendowski on 28/04/2017.
//  Copyright © 2017 Khan Academy. All rights reserved.
//

import Foundation
import UIKit

public typealias TweakActionClosure = () -> Void

public class TweakAction {
	public enum Error: Swift.Error {
		case wrongIdentifier
	}
	
	public typealias ClosureIdentifier = UInt
	
	private var lastToken: ClosureIdentifier = 0
	private var closures: [ClosureIdentifier: TweakActionClosure] = [:]
	
	public init() {}
	
	public func addClosure(_ closure: @escaping TweakActionClosure) -> ClosureIdentifier {
		let nextToken = lastToken + 1
		closures[nextToken] = closure
		lastToken = nextToken
		return nextToken
	}
	
	public func removeClosure(withIdentifier identifier: ClosureIdentifier) throws {
		guard closures.keys.contains(identifier) else {
			throw Error.wrongIdentifier
		}
		closures[identifier] = nil
	}
	
	// MARK: Internal
	
	func evaluateAllClosures() {
		closures.keys.sorted().forEach { closures[$0]?() }
	}
}

extension TweakAction: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .action
	}
}

extension Tweak where T == TweakAction {
	
	public init(_ collectionName: String, _ groupName: String, _ tweakName: String) {
		self.init(collectionName, groupName, tweakName, TweakAction())
	}
	
	@discardableResult
	public func addClosure(_ closure: @escaping TweakActionClosure) -> TweakAction.ClosureIdentifier {
		return defaultValue.addClosure(closure)
	}
	
	public func removeClosure(with identifier: TweakAction.ClosureIdentifier) throws {
		try defaultValue.removeClosure(withIdentifier: identifier)
	}
}
