//
//  TweakCallbacks.swift
//  SwiftTweaks
//
//  Created by Jarosław Pendowski on 28/04/2017.
//  Copyright © 2017 Khan Academy. All rights reserved.
//

import Foundation

public typealias TweakBlock = () -> Void

public class TweakCallbacks {
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
	
	public func removeCallback(with token: CallbackIdentifier) {
		callbacks[token] = nil
	}
	
	// MARK: Internal
	
	func executeAllCallbacks() {
		callbacks.keys.sorted().forEach { callbacks[$0]?() }
	}
}

extension TweakCallbacks: TweakableType {
	public static var tweakViewDataType: TweakViewDataType {
		return .action
	}
}

extension Tweak where T == TweakCallbacks {
	
	public init(_ collectionName: String, _ groupName: String, _ tweakName: String) {
		self.init(collectionName, groupName, tweakName, TweakCallbacks())
	}
	
	public func addCallback(_ callback: @escaping TweakBlock) -> TweakCallbacks.CallbackIdentifier {
		return defaultValue.addCallback(callback)
	}
	
	public func removeCallback(with token: TweakCallbacks.CallbackIdentifier) {
		defaultValue.removeCallback(with: token)
	}
}
