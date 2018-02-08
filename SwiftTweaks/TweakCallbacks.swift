//
//  TweakCallbacks.swift
//  SwiftTweaks
//
//  Created by Jarosław Pendowski on 28/04/2017.
//  Copyright © 2017 Khan Academy. All rights reserved.
//

import Foundation
import UIKit

public typealias TweakBlock = (_ sender: UIView, _ viewController: UIViewController?) -> Void

public class TweakCallbacks {
	public enum Error: Swift.Error {
		case wrongIdentifier
	}
	
	public typealias CallbackIdentifier = UInt
	
	private var lastToken: CallbackIdentifier = 0
	private var callbacks: [CallbackIdentifier: TweakBlock] = [:]
	
	public init() {}
	
	public func addCallback(_ callback: @escaping TweakBlock) -> CallbackIdentifier {
		let nextToken = lastToken + 1
		callbacks[nextToken] = callback
		lastToken = nextToken
		return nextToken
	}
	
	public func removeCallback(with token: CallbackIdentifier) throws {
		guard callbacks.keys.contains(token) else {
			throw Error.wrongIdentifier
		}
		callbacks[token] = nil
	}
	
	// MARK: Internal
	
	func executeAllCallbacks(sender: UIView, viewController: UIViewController?) {
		callbacks.keys.sorted().forEach { callbacks[$0]?(sender, viewController) }
	}
}

extension TweakCallbacks: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .closure
	}
}

extension Tweak where T == TweakCallbacks {
	
	public init(_ collectionName: String, _ groupName: String, _ tweakName: String) {
		self.init(collectionName, groupName, tweakName, TweakCallbacks())
	}
	
	@discardableResult
	public func addCallback(_ callback: @escaping TweakBlock) -> TweakCallbacks.CallbackIdentifier {
		return defaultValue.addCallback(callback)
	}
	
	public func removeCallback(with token: TweakCallbacks.CallbackIdentifier) throws {
		try defaultValue.removeCallback(with: token)
	}
}
