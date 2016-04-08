//
//  HashingUtilities.swift
//  Khan Academy
//
//  Created by Nacho Soto on 1/9/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import Foundation

infix operator ^^^ { associativity left precedence 160 }

public func ^^^<L: Hashable, R: Hashable>(left: L, right: R) -> Int {
	return hash(left, right)
}

public func ^^^(left: Int, right: Int) -> Int {
	return hash(left, right)
}

public func ^^^<R: Hashable>(left: Int, right: R) -> Int {
	return hash(left, right)
}

public func ^^^<L: Hashable>(left: L, right: Int) -> Int {
	return hash(right, left)
}

public func ^^^<L: Hashable, R: Hashable>(left: L, right: R?) -> Int {
	return hash(left, right)
}

public func ^^^<L: Hashable, R: Hashable>(left: L?, right: R) -> Int {
	return hash(right, left)
}

public func ^^^<L: Hashable, R: Hashable>(left: L, right: [R]) -> Int {
	return hash(left, right)
}

public func ^^^<L: Hashable, R: Hashable>(left: [L], right: R) -> Int {
	return hash(right, left)
}

public func ^^^<L: Hashable, R: Hashable>(left: L, right: [R]?) -> Int {
	return hash(left, right)
}

public func ^^^<L: Hashable, R: Hashable>(left: [L]?, right: R) -> Int {
	return hash(right, left)
}


// MARK: Private functions

private func hash<L: Hashable, R: Hashable>(left: L, _ right: R) -> Int {
	return hash(left.hashValue, right)
}

private func hash<L: Hashable, R: Hashable>(left: L, _ right: R?) -> Int {
	if let right = right {
		return hash(left, right)
	} else {
		return left.hashValue
	}
}

private func hash<L: Hashable, R: Hashable>(left: L, _ right: [R]) -> Int {
	return hash(left, hash(right))
}

private func hash<L: Hashable, R: Hashable>(left: L, _ right: [R]?) -> Int {
	if let right = right {
		return hash(left, right)
	} else {
		return left.hashValue
	}
}

private func hash<T: Hashable>(array: [T]) -> Int {
	return array.reduce(0, combine: ^^^)
}

private func hash<R: Hashable>(left: Int, _ right: R) -> Int {
	return Int.addWithOverflow(Int.multiplyWithOverflow(left, HashingPrime).0, right.hashValue).0
}

private let HashingPrime: Int = 31
