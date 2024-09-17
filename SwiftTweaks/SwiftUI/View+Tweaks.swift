//
//  View+Tweaks.swift
//  SwiftTweaks
//
//  Created by Daniel Amitay on 9/16/24.
//  Copyright © 2024 Khan Academy. All rights reserved.
//

// Guarded by SwiftUI to prevent compilation errors when SwiftUI is not available.
#if canImport(SwiftUI)

import SwiftUI

/// Whether the device began or ended shaking
internal enum ShakePhase {
	case began
	case ended
}

@available(iOS 15.0, *)
/// `View` extension to add a shake gesture recognizer.
internal extension View {
	func onShake(_ block: @escaping (_ phase: ShakePhase) -> Void) -> some View {
		self.overlay {
			ShakeViewRepresentable(onShake: block)
				.allowsHitTesting(false)
				.opacity(0.0)
		}
	}
}

@available(iOS 13.0, *)
/// `View` extension to conditionally apply a transformation.
internal extension View {
	@ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

@available(iOS 13.0, *)
/// Hook into the responder chain to detect shake gestures
internal struct ShakeViewRepresentable: UIViewControllerRepresentable {
	let onShake: (ShakePhase) -> ()

	class ShakeViewController: UIViewController {
		let onShake: ((ShakePhase) -> ())
		init(onShake: @escaping (ShakePhase) -> Void) {
			self.onShake = onShake
			super.init(nibName: nil, bundle: nil)
		}
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
			if motion == .motionShake {
				onShake(.began)
			}
			super.motionBegan(motion, with: event)
		}
		override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
			if motion == .motionShake {
				onShake(.ended)
			}
			super.motionEnded(motion, with: event)
		}
	}
	func makeUIViewController(context: Context) -> ShakeViewController {
		return ShakeViewController(onShake: onShake)
	}
	func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {
		// no-op
	}
}

#endif
