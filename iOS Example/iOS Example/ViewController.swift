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
        tweakBindings.insert(ExampleTweaks.bind(ExampleTweaks.featureFlagMainScreenHelperText) { self.bodyLabel.isHidden = !$0 })
        
        // Bind is useful when you want to keep something up to date easily. 
        // To demonstrate - let's apply a bunch of tweaks here in viewDidLoad, 
        // which is only called once in the lifecycle of the view, yet these bindings will update whenever the underlying tweaks change!
        // Note that we're holding on to the `bindingIdentifier`: to avoid memory leaks, we tear down these bindings in `deinit`
        tweakBindings.insert(ExampleTweaks.bind(ExampleTweaks.colorTint) { self.bounceButton.backgroundColor = $0 })
        tweakBindings.insert(ExampleTweaks.bind(ExampleTweaks.colorButtonText) { self.bounceButton.setTitleColor($0, for: .normal) })
        tweakBindings.insert(ExampleTweaks.bind(ExampleTweaks.colorBackground) { self.view.backgroundColor = $0 })
        tweakBindings.insert(ExampleTweaks.bind(ExampleTweaks.colorText1) { self.titleLabel.textColor = $0; self.bodyLabel.textColor = $0 })
        tweakBindings.insert(ExampleTweaks.bind(ExampleTweaks.colorText2) { self.subtitleLabel.textColor = $0 })

        // The above examples used very concise syntax - that's because Swift makes it easy to write concisely!
        // Of course, you can write binding closures in a more verbose syntax if you find it easier to read, like this:
        tweakBindings.insert(ExampleTweaks.bind(ExampleTweaks.fontSizeText1) { fontSize in
            self.titleLabel.font = UIFont.systemFont(ofSize: fontSize)
        })
        
        let binding = ExampleTweaks.bind(ExampleTweaks.title) { (title: StringOption) in
            self.titleLabel.text = title.value
        }
        tweakBindings.insert(binding)
        
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
        
        let multipleBinding = ExampleTweaks.bindMultiple(tweaksToWatch) {
            // This closure will be called immediately,
            // and then again each time *any* of the tweaksToWatch change.
            self.layoutContentsOfView()
        }
        multiTweakBindings.insert(multipleBinding)

        // You can even run code with a tweak! 
        // There are *so* many use cases for this - maybe you need a way to clear a cache, or force a crash, or any number of other things.
        // With `TweaksCallbacks`, you can add callbacks to tweaks, and they will be called when that tweak is tapped in the SwiftTweaks menu.

        ExampleTweaks.actionPrintToConsole.addClosure {
            print("🤖 I'm sorry Dave")
        }
        ExampleTweaks.actionPrintToConsole.addClosure {
            print("🤖 I'm afraid I can't do that")
        }
        
        // You can remove a callback with the identifier returned from `addCallback`.
        let callbackIdentifier = ExampleTweaks.actionPrintToConsole.addClosure {
            // this won't be run
            print("👩🏻‍🚀 <turns off HAL>")
        }
        _ = try? ExampleTweaks.actionPrintToConsole.removeClosure(with: callbackIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Use the `assign` value to get the currentValue of a tweak once.
        // With `assign`, you get the value only once - when the tweak updates, you won't be notified.
        // Since this is in viewWillAppear, though, this re-application will update right before the view appears onscreen!
        view.backgroundColor = ExampleTweaks.assign(ExampleTweaks.colorBackground)
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
        self.tweakBindings.forEach(ExampleTweaks.unbind)
        self.multiTweakBindings.forEach(ExampleTweaks.unbindMultiple)
    }
    
    
    // MARK: Subviews
    private func layoutContentsOfView() {
        let titleLabelFontSize = ExampleTweaks.assign(ExampleTweaks.fontSizeText1)
        let bodyLabelFontSize = ExampleTweaks.assign(ExampleTweaks.fontSizeText2)
        let horizontalMargins = ExampleTweaks.assign(ExampleTweaks.horizontalMargins)
        let verticalGapBetweenLabels = ExampleTweaks.assign(ExampleTweaks.verticalMargins)
        
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
            springTweakTemplate: ExampleTweaks.buttonAnimation,
            tweakStore: ExampleTweaks.defaultStore,
            options: .beginFromCurrentState,
            animations: { 
                self.bounceButton.frame = originalFrame.offsetBy(dx: 0, dy: 200)
        },
            completion: { _ in
                UIView.animate(
                    springTweakTemplate: ExampleTweaks.buttonAnimation,
                    tweakStore: ExampleTweaks.defaultStore,
                    options: .beginFromCurrentState,
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
