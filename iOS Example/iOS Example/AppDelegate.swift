//
//  AppDelegate.swift
//  iOS Example
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window!.rootViewController = ViewController()
		window!.makeKeyAndVisible()

		return true
	}
}

