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

@available(iOS 14.0, *)
/// A `Scene` that presents a `TweakStore` UI when a certain gesture is recognized.
/// Use this in place of the WindowGroup in your App's @main struct.
struct TweakWindowGroup<Content: View>: Scene {

	enum GestureType {
		/// Shake the device, like you're trying to undo some text
		case shake
		/// Two-finger double-taps are not natively supported in SwiftUI yet
	}

	/// The GestureType used to determine when to present the UI.
	let gestureType: GestureType
	/// The TweakStore to use for the UI.
	let tweakStore: TweakStore
	/// Your app's content.
	let content: () -> Content

	/// Whether or not the Tweak UI is currently being shown.
	@State private var showingTweaks: Bool = false

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
		}
    }
}

#endif
