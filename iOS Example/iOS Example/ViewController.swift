//
//  ViewController.swift
//  iOS Example
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit
import SwiftTweaks

class ViewController: UIViewController {

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = NSTextAlignment.Center
		label.text = "SwiftTweaks"
		return label
	}()

	private let bodyLabel: UILabel = {
		let label = UILabel()
		label.text = "Shake your device to bring up the Tweaks UI. Make your changes, and when you dismiss, you'll see 'em applied here! You can even force-quit the app and the changes will persist!"
		label.numberOfLines = 0
		label.lineBreakMode = .ByWordWrapping
		return label
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(titleLabel)
		view.addSubview(bodyLabel)

		// Here's a demonstration of TweakLibraryType.bind() - the underlying tweak value is immediately applied, and the binding is re-called each time the tweak changes.
		ExampleTweaks.bind(ExampleTweaks.titleScreenShowHelperText) { self.bodyLabel.hidden = !$0 }

		// Bind is useful when you want to keep something up to date easily. To demonstrate - let's apply a bunch of tweaks here in viewDidLoad, which is only called once in the lifecycle of the view, yet these bindings will update whenever the underlying tweaks change!
		ExampleTweaks.bind(ExampleTweaks.colorBackground) { self.view.backgroundColor = $0 }
		ExampleTweaks.bind(ExampleTweaks.colorText1) { self.titleLabel.textColor = $0 }

		// The above examples used very concise syntax - that's because Swift makes it easy to write concisely!
		// Of course, you can write binding closures in a more verbose syntax if you find it easier to read, like this:
		ExampleTweaks.bind(ExampleTweaks.fontSizeText1) { fontSize in
			self.titleLabel.font = UIFont.systemFontOfSize(fontSize)
		}

		// Now let's look at a trickier example: let's say that you have a layout, and it depends on multiple tweaks. 
		// In our case, we have tweaks for two font sizes, as well as two layout parameters (horizontal margins and vertical padding between the labels). 
		// What we'll do in this case is create a layout closure, and then call it each time any of those tweaks change. You could also call an existing function (like `layoutSubviews` or something like that) in place of this closure.
		// You'll note that inside the closure, we're calling `assign` to get the current value.
		let layoutClosure: () -> Void = {
			let titleLabelFontSize = ExampleTweaks.assign(ExampleTweaks.fontSizeText1)
			let bodyLabelFontSize = ExampleTweaks.assign(ExampleTweaks.fontSizeText2)
			let horizontalMargins = ExampleTweaks.assign(ExampleTweaks.horizontalMargins)
			let verticalGapBetweenLabels = ExampleTweaks.assign(ExampleTweaks.titleScreenGapBetweenTitleAndBody)

			self.titleLabel.font = UIFont.systemFontOfSize(titleLabelFontSize)
			self.titleLabel.sizeToFit()
			self.titleLabel.frame = CGRect(
				origin: CGPoint(x: horizontalMargins, y: 30),
				size: CGSize(
					width: self.view.bounds.width - horizontalMargins * 2,
					height: self.titleLabel.bounds.height
				)
			)

			self.bodyLabel.font = UIFont.systemFontOfSize(bodyLabelFontSize)
			self.bodyLabel.frame = CGRect(
				origin: CGPoint(
					x: horizontalMargins,
					y: CGRectGetMaxY(self.titleLabel.frame) + verticalGapBetweenLabels),
				size: self.bodyLabel.sizeThatFits(
					CGSize(width: self.view.bounds.width - horizontalMargins * 2, height: CGFloat.max)
				)
			)
		}
		ExampleTweaks.bind(ExampleTweaks.fontSizeText1) { _ in layoutClosure() }
		ExampleTweaks.bind(ExampleTweaks.fontSizeText2) { _ in layoutClosure() }
		ExampleTweaks.bind(ExampleTweaks.horizontalMargins) { _ in layoutClosure() }
		ExampleTweaks.bind(ExampleTweaks.titleScreenGapBetweenTitleAndBody) { _ in layoutClosure() }
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		// Use the `assign` value to get the currentValue of a tweak once.
		// With `assign`, you get the value once - and when the tweak updates, you won't be notified.
		// The benefit of this approach is that the
		// Since this is in viewWillAppear, though, this re-application will update right before the view appears onscreen!
		view.backgroundColor = ExampleTweaks.assign(ExampleTweaks.colorBackground)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}