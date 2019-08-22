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

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        self.window = AutomaticTweaks.window(from: self.window) 
        #endif

		/*	Note: if you're using the shake gesture for something else (say, React Native) then you have two options:
				1. Use the .twoFingerDoubleTap gesture, like so:
					
                    self.window = AutomaticTweaks.window(
                        from: self.window,
						gestureType: .twoFingerDoubleTap
					)
				2. Use a custom gesture recognizer of your choice, like so:
					
					let customGesture = UITapGestureRecognizer()
					customGesture.numberOfTapsRequired = 3
					customGesture.numberOfTouchesRequired = 3
                    self.window = AutomaticTweaks.window(
                        from: self.window,
						gestureType: .gesture(customGesture),
						tweakStore: ExampleTweaks.defaultStore
					)

					For a lil extra flexibility, we leave it to you to decide what view you'd like to gesture with.
					To use the whole window, do this:

					window.addGestureRecognizer(customGesture)
		*/

        if publicTweaks.logDebugOnStartup.currentValue {
            print("We're starting up")
        }
        
		window!.rootViewController = ViewController()
		window!.makeKeyAndVisible()

		return true
	}
}

