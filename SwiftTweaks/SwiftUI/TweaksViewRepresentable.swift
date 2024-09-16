//
//  TweaksViewRepresentable.swift
//  SwiftTweaks
//
//  Created by Daniel Amitay on 9/16/24.
//  Copyright © 2024 Khan Academy. All rights reserved.
//

#if	canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
/// A `UIViewControllerRepresentable` that presents the `TweaksViewController`.
struct TweaksViewRepresentable: UIViewControllerRepresentable {
	let tweakStore: TweakStore
	let showingTweaks: Binding<Bool>

	init(
		tweakStore: TweakStore,
		showingTweaks: Binding<Bool>
	) {
		self.tweakStore = tweakStore
		self.showingTweaks = showingTweaks
	}

	func makeUIViewController(context: Context) -> TweaksViewController {
		let delegate = RepresentableDelegate(showingTweaks: showingTweaks)
		return TweaksViewController(
			tweakStore: tweakStore,
			delegate: delegate
		)
	}

	func updateUIViewController(_ uiViewController: TweaksViewController, context: Context) {
		// no-op
	}
}

@available(iOS 13.0, *)
class RepresentableDelegate: TweaksViewControllerDelegate {
	@Binding var showingTweaks: Bool

	init(showingTweaks: Binding<Bool>) {
		self._showingTweaks = showingTweaks
	}

	func tweaksViewControllerRequestsDismiss(_ tweaksViewController: TweaksViewController, completion: (() -> ())?) {
		showingTweaks = false
		completion?()
	}
}

@available(iOS 13.0, *)
#Preview {
	TweaksViewRepresentable(
		tweakStore: .init(tweaks: [], enabled: true),
		showingTweaks: .constant(true)
	)
}

#endif
