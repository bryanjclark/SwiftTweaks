//
//  TweakDebug.swift
//  SwiftTweaks
//
//  Created by Aymeric Gallissot on 6/1/2016.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

/// A helper that looks up whether you're in a `DEBUG` build;
/// useful for determining when to enable your `TweakStore`.
public struct TweakDebug {
    public static var isActive: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()
}