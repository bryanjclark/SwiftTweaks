//
//  ViewController.swift
//  iOS Example
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit
import SwiftTweaks


// The following tweaks are all file private to this view controller, but will still
// show up in the list of AutomaticTweaks

fileprivate let exampleTweaks = ExampleTweaks()

fileprivate class ExampleTweaks: AutomaticTweakList {
    public static var tweakList: AutomaticTweakList = exampleTweaks
    
	public let colorBackground = Tweak("General", "Colors", "Background", UIColor(white: 0.98, alpha: 1.0))
	public let colorTint = Tweak("General", "Colors", "Tint", UIColor(hue: 5/255, saturation: 0.61, brightness: 0.89, alpha: 1))
	public let colorButtonText = Tweak("General", "Colors", "Button Text", UIColor.white)

	// Tweaks work *great* with numbers, you just need to tell the compiler
	// what kind of number you're using (Int, CGFloat, or Double)
	public let fontSizeText1 = Tweak<CGFloat>("Text", "Font Sizes", "title", 32)
	public let fontSizeText2 = Tweak<CGFloat>("Text", "Font Sizes", "body", 18)

	// If the tweak is for a number, you can optionally add default / min / max / stepSize options to restrict the values.
	// Maybe you've got a number that must be non-negative, for example:
	public let horizontalMargins = Tweak<CGFloat>("General", "Layout", "H. Margins", defaultValue: 16, min: 0)
	public let verticalMargins = Tweak<CGFloat>("General", "Layout", "V. Margins", defaultValue: 16, min: 0)

	public let colorText1 = Tweak("Text", "Color", "text-1", UIColor.black)
	public let colorText2 = Tweak("Text", "Color", "text-2", UIColor(hue: 213/255, saturation: 0.07, brightness: 0.58, alpha: 1))

    public let title = Tweak("Text", "Text", "Title", options: ["SwiftTweaks", "Welcome!", "Example"])
	public let subtitle = Tweak<String>("Text", "Text", "Subtitle", "Subtitle")

	// Tweaks are often used in combination with each other, so we have some templates available for ease-of-use:
	public let buttonAnimation = SpringAnimationTweakTemplate("Animation", "Button Animation", duration: 0.5) // Note: "duration" is optional, if you don't provide it, there's a sensible default!

    // You can even run your own code from a tweak! More on this in this example's ViewController.swift file
    public let actionPrintToConsole = Tweak<TweakAction>("General", "Actions", "Print to console")
    
    /*
	Seriously, SpringAnimationTweakTemplate is *THE BEST* - here's what the equivalent would be if you were to make that by hand:

	public let animationDuration = Tweak<Double>("Animation", "Button Animation", "Duration", defaultValue: 0.5, min: 0.0)
	public let animationDelay = Tweak<Double>("Animation", "Button Animation", "Delay", defaultValue: 0.0, min: 0.0, max: 1.0)
	public let animationDamping = Tweak<CGFloat>("Animation", "Button Animation", "Damping", defaultValue: 0.7, min: 0.0, max: 1.0)
	public let animationVelocity = Tweak<CGFloat>("Animation", "Button Animation", "Initial V.", 0.0)

	*/

	public let featureFlagMainScreenHelperText = Tweak("Feature Flags", "Main Screen", "Show Body Text", true)

    // we only define tweaks here, nothing else
}

class ViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "SwiftTweaks"
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "github.com/Khan/SwiftTweaks"
        return label
    }()

	private let bodyLabel: UILabel = {
		let label = UILabel()
		label.text = "Shake your device to bring up the Tweaks UI. Make your changes, and when you dismiss, you'll see 'em applied here! You can even force-quit the app and the changes will persist!"
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()

	private let bounceButton: UIButton = {
		let button = UIButton()
		button.setTitle("Animate", for: UIControl.State())
		button.layer.cornerRadius = 5
		button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 32, bottom: 14, right: 32)
		return button
	}()

	private var tweakBindings = Set<TweakBindingIdentifier>()
	private var multiTweakBindings = Set<MultiTweakBindingIdentifier>()

	override func viewDidLoad() {
		super.viewDidLoad()
        
        [titleLabel, subtitleLabel, bodyLabel, bounceButton].forEach(view.addSubview)
        
        bounceButton.addTarget(self, action: #selector(bounceButtonPressed(_:)), for: .touchUpInside)
        
        // Here's a demonstration of TweakLibraryType.bind() - the underlying tweak value is immediately applied, and the binding is re-called each time the tweak changes.
        tweakBindings.insert(exampleTweaks.featureFlagMainScreenHelperText.bind { self.bodyLabel.isHidden = !$0 })
        
        // Bind is useful when you want to keep something up to date easily. 
        // To demonstrate - let's apply a bunch of tweaks here in viewDidLoad, 
        // which is only called once in the lifecycle of the view, yet these bindings will update whenever the underlying tweaks change!
        // Note that we're holding on to the `bindingIdentifier`: to avoid memory leaks, we tear down these bindings in `deinit`
        tweakBindings.insert(exampleTweaks.colorTint.bind { self.bounceButton.backgroundColor = $0 })
        tweakBindings.insert(exampleTweaks.colorButtonText.bind { self.bounceButton.setTitleColor($0, for: .normal) })
        tweakBindings.insert(exampleTweaks.colorBackground.bind { self.view.backgroundColor = $0 })
        tweakBindings.insert(exampleTweaks.colorText1.bind { self.titleLabel.textColor = $0; self.bodyLabel.textColor = $0 })
        tweakBindings.insert(exampleTweaks.colorText2.bind { self.subtitleLabel.textColor = $0 })

        // The above examples used very concise syntax - that's because Swift makes it easy to write concisely!
        // Of course, you can write binding closures in a more verbose syntax if you find it easier to read, like this:
        tweakBindings.insert(exampleTweaks.fontSizeText1.bind { fontSize in
            self.titleLabel.font = UIFont.systemFont(ofSize: fontSize)
        })
        
        let binding = exampleTweaks.title.bind { (title: StringOption) in
            self.titleLabel.text = title.value
        }
        tweakBindings.insert(binding)
        
        // Now let's look at a trickier example: let's say that you have a layout, and it depends on multiple tweaks. 
        // In our case, we have tweaks for two font sizes, as well as two layout parameters (horizontal margins and vertical padding between the labels). 
        // What we'll do in this case is create a layout closure, and then call it each time any of those tweaks change. You could also call an existing function (like `layoutSubviews` or something like that) instead of creating a closure.
        // Note that inside this closure, we're calling `assign` to get the current value.
        let tweaksToWatch: [TweakType] = [
            exampleTweaks.fontSizeText1,
            exampleTweaks.fontSizeText2,
            exampleTweaks.horizontalMargins,
            exampleTweaks.verticalMargins
        ]
        
        let multipleBinding = AutomaticTweaks.bindMultiple(tweaksToWatch) {
            // This closure will be called immediately,
            // and then again each time *any* of the tweaksToWatch change.
            self.layoutContentsOfView()
        }
        multiTweakBindings.insert(multipleBinding)

        // You can even run code with a tweak! 
        // There are *so* many use cases for this - maybe you need a way to clear a cache, or force a crash, or any number of other things.
        // With `TweaksCallbacks`, you can add callbacks to tweaks, and they will be called when that tweak is tapped in the SwiftTweaks menu.

        exampleTweaks.actionPrintToConsole.addClosure {
            print("🤖 I'm sorry Dave")
        }
        exampleTweaks.actionPrintToConsole.addClosure {
            print("🤖 I'm afraid I can't do that")
        }
        
        // You can remove a callback with the identifier returned from `addCallback`.
        let callbackIdentifier = exampleTweaks.actionPrintToConsole.addClosure {
            // this won't be run
            print("👩🏻‍🚀 <turns off HAL>")
        }
        _ = try? exampleTweaks.actionPrintToConsole.removeClosure(with: callbackIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Use the `currentValue` value to get the currentValue of a tweak once.
        // With `currentValue`, you get the value only once - when the tweak updates, you won't be notified.
        // Since this is in viewWillAppear, though, this re-application will update right before the view appears onscreen!
        view.backgroundColor = exampleTweaks.colorBackground.currentValue
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
            self.layoutContentsOfView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // Here's where we tear-down the tweak bindings that we used above.
        self.tweakBindings.forEach(AutomaticTweaks.unbind)
        self.multiTweakBindings.forEach(AutomaticTweaks.unbindMultiple)
    }
    
    
    // MARK: Subviews
    private func layoutContentsOfView() {
        let titleLabelFontSize = exampleTweaks.fontSizeText1.currentValue
        let bodyLabelFontSize = exampleTweaks.fontSizeText2.currentValue
        let horizontalMargins = exampleTweaks.horizontalMargins.currentValue
        let verticalGapBetweenLabels = exampleTweaks.verticalMargins.currentValue
        
        self.titleLabel.font = UIFont.systemFont(ofSize: titleLabelFontSize, weight: UIFont.Weight.bold)
        self.titleLabel.sizeToFit()
        let safeAreaInsets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeAreaInsets = self.view.safeAreaInsets
        } else {
            safeAreaInsets = .zero
        }
        self.titleLabel.frame = CGRect(
            origin: CGPoint(
                x: horizontalMargins,
                y: 30 + safeAreaInsets.top),
            size: CGSize(
                width: self.view.bounds.width - horizontalMargins * 2,
                height: self.titleLabel.bounds.height
            )
        )
        
        self.subtitleLabel.font = UIFont.systemFont(ofSize: bodyLabelFontSize)
        self.subtitleLabel.sizeToFit()
        self.subtitleLabel.frame = CGRect(
            origin: CGPoint(x: horizontalMargins, y: self.titleLabel.frame.maxY),
            size: CGSize(width: self.titleLabel.frame.width, height: self.subtitleLabel.frame.size.height)
        )
        
        
        self.bodyLabel.font = UIFont.systemFont(ofSize: bodyLabelFontSize)
        self.bodyLabel.frame = CGRect(
            origin: CGPoint(
                x: horizontalMargins,
                y: self.subtitleLabel.frame.maxY + verticalGapBetweenLabels),
            size: self.bodyLabel.sizeThatFits(
                CGSize(width: self.view.bounds.width - horizontalMargins * 2, height: CGFloat.greatestFiniteMagnitude)
            )
        )
        
        self.bounceButton.sizeToFit()
        self.bounceButton.frame = CGRect(
            origin: CGPoint(
                x: self.view.center.x - self.bounceButton.bounds.width / 2,
                y: self.bodyLabel.frame.maxY + verticalGapBetweenLabels
            ), size: self.bounceButton.bounds.size
        )
    }
    
    
    // MARK: Events
    
    @objc private func bounceButtonPressed(_ sender: UIButton) {
        
        let originalFrame = self.bounceButton.frame
        
        // To help make TweakGroupTemplateSpringAnimation even more useful - check this out:
        UIView.animate(
            springTweakTemplate: exampleTweaks.buttonAnimation,
            tweakStore: AutomaticTweaks.defaultStore,
            options: .beginFromCurrentState,
            animations: { 
                self.bounceButton.frame = originalFrame.offsetBy(dx: 0, dy: 200)
        },
            completion: { _ in
                UIView.animate(
                    springTweakTemplate: exampleTweaks.buttonAnimation,
                    tweakStore: AutomaticTweaks.defaultStore,
                    options: .beginFromCurrentState,
                    animations: {
                        self.bounceButton.frame = originalFrame
                },
                    completion: nil
                )
        }
        )
        
        /* Of course, you don't *have* to use the helper method; you can grab the individual tweaks quite easily:
         
         let duration = exampleTweaks.buttonAnimation.duration.currentValue
         let delay = exampleTweaks.buttonAnimation.delay.currentValue
         let damping = exampleTweaks.buttonAnimation.damping.currentValue
         let velocity = exampleTweaks.buttonAnimation.initialSpringVelocity.currentValue
         
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
