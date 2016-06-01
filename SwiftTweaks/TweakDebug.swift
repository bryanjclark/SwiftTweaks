//
//  TweakDebug.swift
//  SwiftTweaks
//
//  Created by Aymeric Gallissot on 6/1/2016.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

public struct TweakDebug {
    public static var isActive: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()
}