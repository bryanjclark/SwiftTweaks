//
//  TweakableType.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

/// Declares what types are supported as Tweaks.
/// Currently an empty protocol, but in the future we will likely ask TweakableTypes to generate UI.
public protocol TweakableType { }

// The following types are supported as Tweaks.
extension CGFloat: TweakableType { }
extension Int: TweakableType { }
extension String: TweakableType { }
extension UIColor: TweakableType { }
extension Bool: TweakableType { }