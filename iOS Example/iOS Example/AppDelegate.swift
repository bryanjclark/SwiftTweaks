//
//  AppDelegate.swift
//  iOS Example
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit
import SwiftTweaks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		window = TweakWindow(frame: UIScreen.main.bounds, tweakStore: ExampleTweaks.defaultStore)
		window!.rootViewController = ViewController()
		window!.makeKeyAndVisible()

		return true
	}
}

