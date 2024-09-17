//
//  TweakWindowGroup.swift
//  SwiftTweaks
//
//  Created by Daniel Amitay on 9/16/24.
//  Copyright © 2024 Khan Academy. All rights reserved.
//

// Guarded by SwiftUI to prevent compilation errors when SwiftUI is not available.
#if canImport(SwiftUI)

import SwiftUI

@available(iOS 15.0, *)
/// A `Scene` that presents a `TweakStore` UI when a certain gesture is recognized.
/// Use this in place of the WindowGroup in your App's @main struct.
struct TweakWindowGroup<Content: View>: Scene {
	enum GestureType {
		/// Shake the device, like you're trying to undo some text
		case shake
	}

	/// The GestureType used to determine when to present the UI.
	let gestureType: GestureType
	/// The TweakStore to use for the UI.
	let tweakStore: TweakStore
	/// Your app's content.
	let content: () -> Content

	/// Whether or not the Tweak UI is currently being shown.
	@State private var showingTweaks: Bool = false
	/// Whether or not the device is currently being shaken.
	@State private var shaking: Bool = false

	/// The amount of time you need to shake your device to bring up the Tweaks UI
	private let shakeWindowTimeInterval: TimeInterval = 0.4

	public init(
		gestureType: GestureType = .shake,
		tweakStore: TweakStore,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.gestureType = gestureType
		self.tweakStore = tweakStore
		self.content = content
	}

	var body: some Scene {
		WindowGroup {
			VStack {
				content()
			}
			.sheet(isPresented: $showingTweaks) {
				TweaksViewRepresentable(
					tweakStore: tweakStore,
					showingTweaks: $showingTweaks
				)
			}
			.if(gestureType == .shake && tweakStore.enabled) { view in
				view.onShake { phase in
					switch phase {
					case .began:
						shaking = true
						DispatchQueue.main.asyncAfter(deadline: .now() + shakeWindowTimeInterval) {
							if self.shouldShakePresentTweaks {
								self.showingTweaks = true
							}
						}
					case .ended:
						shaking = false
					}
				}
			}
		}
	}
}

@available(iOS 15.0, *)
extension TweakWindowGroup {
	/// We need to know if we're running in the simulator (because shake gestures don't have a time duration in the simulator)
	var runningInSimulator: Bool {
#if targetEnvironment(simulator)
		return true
#else
		return false
#endif
	}

	/// We only want to present the Tweaks UI if we're shaking the device and the Tweaks UI is enabled
	var shouldShakePresentTweaks: Bool {
		if tweakStore.enabled {
			switch gestureType {
			case .shake: return shaking || runningInSimulator
			}
		} else {
			return false
		}
	}
}

#endif
