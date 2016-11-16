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

	private let bounceButton: UIButton = {
		let button = UIButton()
		button.setTitle("Animate", forState: .Normal)
		ExampleTweaks.bind(ExampleTweaks.colorTint) { button.backgroundColor = $0 }
		ExampleTweaks.bind(ExampleTweaks.colorButtonText) { button.setTitleColor($0, forState: .Normal) }
		button.layer.cornerRadius = 5
		button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		bounceButton.addTarget(self, action: #selector(self.bounceButtonPressed(_:)), forControlEvents: .TouchUpInside)
		view.addSubview(titleLabel)
		view.addSubview(bodyLabel)
		view.addSubview(bounceButton)

		// Here's a demonstration of TweakLibraryType.bind() - the underlying tweak value is immediately applied, and the binding is re-called each time the tweak changes.
		ExampleTweaks.bind(ExampleTweaks.featureFlagMainScreenHelperText) { self.bodyLabel.hidden = !$0 }

		// Bind is useful when you want to keep something up to date easily. To demonstrate - let's apply a bunch of tweaks here in viewDidLoad, which is only called once in the lifecycle of the view, yet these bindings will update whenever the underlying tweaks change!
		ExampleTweaks.bind(ExampleTweaks.colorBackground) { self.view.backgroundColor = $0 }
		ExampleTweaks.bind(ExampleTweaks.colorText1) { self.titleLabel.textColor = $0 }
		ExampleTweaks.bind(ExampleTweaks.colorText2) { self.bodyLabel.textColor = $0 }

		// The above examples used very concise syntax - that's because Swift makes it easy to write concisely!
		// Of course, you can write binding closures in a more verbose syntax if you find it easier to read, like this:
		ExampleTweaks.bind(ExampleTweaks.fontSizeText1) { fontSize in
			self.titleLabel.font = UIFont.systemFontOfSize(fontSize)
		}

        ExampleTweaks.bind(ExampleTweaks.title) { (title: StringOption) in
            self.titleLabel.text = title.value
        }

		// Now let's look at a trickier example: let's say that you have a layout, and it depends on multiple tweaks. 
		// In our case, we have tweaks for two font sizes, as well as two layout parameters (horizontal margins and vertical padding between the labels). 
		// What we'll do in this case is create a layout closure, and then call it each time any of those tweaks change. You could also call an existing function (like `layoutSubviews` or something like that) instead of creating a closure.
		// Note that inside this closure, we're calling `assign` to get the current value.
		let tweaksToWatch: [TweakType] = [
			ExampleTweaks.fontSizeText1,
			ExampleTweaks.fontSizeText2,
			ExampleTweaks.horizontalMargins,
			ExampleTweaks.verticalMargins
			]

		ExampleTweaks.bindMultiple(tweaksToWatch) {
			// This closure will be called immediately, and then again each time *any* of the tweaksToWatch change.
			let titleLabelFontSize = ExampleTweaks.assign(ExampleTweaks.fontSizeText1)
			let bodyLabelFontSize = ExampleTweaks.assign(ExampleTweaks.fontSizeText2)
			let horizontalMargins = ExampleTweaks.assign(ExampleTweaks.horizontalMargins)
			let verticalGapBetweenLabels = ExampleTweaks.assign(ExampleTweaks.verticalMargins)

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

			self.bounceButton.sizeToFit()
			self.bounceButton.frame = CGRect(
				origin: CGPoint(
					x: self.view.center.x - self.bounceButton.bounds.width / 2,
					y: CGRectGetMaxY(self.bodyLabel.frame) + verticalGapBetweenLabels
				), size: self.bounceButton.bounds.size
			)
		}
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		// Use the `assign` value to get the currentValue of a tweak once.
		// With `assign`, you get the value only once - when the tweak updates, you won't be notified.
		// Since this is in viewWillAppear, though, this re-application will update right before the view appears onscreen!
		view.backgroundColor = ExampleTweaks.assign(ExampleTweaks.colorBackground)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	// MARK: Events

	@objc private func bounceButtonPressed(sender: UIButton) {

		let originalFrame = self.bounceButton.frame

		// To help make TweakGroupTemplateSpringAnimation even more useful - check this out:
		UIView.animateWithSpringAnimationTweakTemplate(
			ExampleTweaks.buttonAnimation,
			tweakStore: ExampleTweaks.defaultStore,
			options: .BeginFromCurrentState,
			animations: { 
				self.bounceButton.frame = CGRectOffset(originalFrame, 0, 200)
			},
			completion: { _ in
				UIView.animateWithSpringAnimationTweakTemplate(
					ExampleTweaks.buttonAnimation,
					tweakStore: ExampleTweaks.defaultStore,
					options: .BeginFromCurrentState,
					animations: {
						self.bounceButton.frame = originalFrame
					},
					completion: nil
				)
			}
		)

		/* Of course, you don't *have* to use the helper method; you can grab the individual tweaks quite easily:

		let duration = ExampleTweaks.assign(ExampleTweaks.buttonAnimation.duration)
		let delay = ExampleTweaks.assign(ExampleTweaks.buttonAnimation.delay)
		let damping = ExampleTweaks.assign(ExampleTweaks.buttonAnimation.damping)
		let velocity = ExampleTweaks.assign(ExampleTweaks.buttonAnimation.initialSpringVelocity)

		UIView.animateWithDuration(
			duration, 
			delay: delay,
			usingSpringWithDamping: damping,
			initialSpringVelocity: velocity,
			options: UIViewAnimationOptions.BeginFromCurrentState,
			animations: { () -> Void in
				self.bounceButton.frame = CGRectOffset(originalFrame, 0, 200)
			}, 
			completion: { _ in
				UIView.animateWithDuration(
					duration,
					delay: delay,
					usingSpringWithDamping: damping,
					initialSpringVelocity: velocity,
					options: UIViewAnimationOptions.BeginFromCurrentState,
					animations: { () -> Void in
						self.bounceButton.frame = originalFrame
					},
					completion: nil
				)
			}
		)

		*/
	}
}