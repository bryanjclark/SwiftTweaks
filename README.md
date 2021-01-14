# SwiftTweaks

_Adjust your iOS app on the fly without waiting to re-compile!_

![SwiftTweaks Icon](https://github.com/Khan/SwiftTweaks/blob/master/Images/SwiftTweaks_README_icon.png?raw=true)

Your users won’t see your animation study, Sketch comps, or prototypes. What they will see is the finished product - so it’s really important to make sure that your app feels right on a real device!

Animations that look great on your laptop often feel too slow when in-hand. Layouts that looks perfect on a 27-inch display might be too cramped on a 4-inch device. Light gray text may look subtle in Sketch, but it’s downright illegible when you’re outside on a sunny day.

These animation timings, font sizes, and color choices are all examples of “magic numbers” - the constants that give your app its usability and identity. The goal of SwiftTweaks: allow you to fine-tune these magic numbers in the debug builds of your Swift project, without having to wait for Xcode to rebuild the app.

![Tweaks](https://github.com/Khan/SwiftTweaks/blob/master/Images/SwiftTweaks%20Overview.png?raw=true)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](http://img.shields.io/cocoapods/v/SwiftTweaks.svg)](http://cocoapods.org/?q=SwiftTweaks)
[![GitHub release](https://img.shields.io/github/release/Khan/SwiftTweaks.svg)](https://github.com/Khan/SwiftTweaks/releases)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
![platforms](https://img.shields.io/badge/platforms-iOS%20-lightgrey.svg)
[![Build Status](https://travis-ci.org/Khan/SwiftTweaks.svg?branch=master)](https://travis-ci.org/Khan/SwiftTweaks)

## Overview

Use a `Tweak` in place of a boolean, number, or color in your code. You can adjust that `Tweak` without having to recompile, which means you can play with animation timings, colors, and layouts without needing Xcode!

Currently, you can tweak the following types:

- `Bool`
- `Int`
- `CGFloat`
- `Double`
- `UIColor`
- [`TweakAction`](#Actions)
- `String`
- `StringOption`

A `Tweak` looks like this:

```swift
public static let colorTint = Tweak("General", "Colors", "Tint", UIColor.blueColor())
```

There are also helpful `TweakGroupTemplate` types, so you can quickly declare commonly-used-together combos. They all have sensible defaults, but of course, you can set your own!

```swift
// Controls delay and duration for UIView.animate
// Use it with UIView.animate(basicTweakTemplate:...)
public static let basicAnimation = BasicAnimationTweakTemplate("Animation", "Basic Animation")

// Controls delay, duration, damping, and initial spring velocity for UIView.animate
// Use it with UIView.animate(springTweakTemplate:...)
public static let springAnimation = SpringAnimationTweakTemplate("Animation", "Spring Animation")

// Controls shadow color, radius, offset, and opacity for CALayer
// Use it with CALayer.apply(shadowTweakTemplate:...)
public static let shadowTweak = ShadowTweakTemplate("Shadows", "Button Shadow")

// Controls top/right/bottom/left for UIEdgeInsets
// Use it with UIEdgeInsets.init(edgeInsetsTweakTemplate)
public static let edgeInsets = EdgeInsetsTweakTemplate("Layout", "Screen Edge Insets")
```

Of course, you can create your own `TweakGroupTemplate` type if you'd like - they're handy whenever you have a cluster of tweaks that need to be used together to get a desired effect. They can be built out of any combination of `Tweak`s.

![Tweaks](https://github.com/Khan/SwiftTweaks/blob/master/Images/SwiftTweaks%20Demo.gif?raw=true)

### Actions

SwiftTweaks now supports closures, so you can perform actions that do not depend on data from SwiftTweaks. To do this, use `TweakAction` as a type in your `TweakStore` to create a Tweak that executes your custom closures:

```swift
public static let action = Tweak<TweakAction>("Actions", "Action", "Perform some action")
```

Later in the code you can add closures to that tweak, which are executed when a button in Tweaks window is pressed.

```swift
let idenfitier = ExampleTweaks.action.addClosure {
	/// Some complicated action happens here
	print("We're all done!")
}
```

If you want to, you can also always remove closure using unique idenfitier that `addClosure` method provides.

```swift
ExampleTweaks.action.removeClosure(with: idenfitier)
```

### Wait, what about [Facebook Tweaks](https://github.com/facebook/Tweaks)?

Good question! I’m glad you asked. **The whole reason SwiftTweaks exists is because we love the stuffing out of FBTweaks.** We’re long-time fans of FBTweaks in our Objective-C projects: Replace the magic numbers with an `FBTweak` macro, and you’re all set! You can leave an FBTweak macro in your production code, because it’s replaced at compile-time with the tweak’s default value.

But Swift doesn’t support this macro-wizardry, so FBTweaks is burdensome to use in Swift code. Our app is nearly all Swift, so we wanted to see if we could make something that was a little easier!

## Steps to Tweaking

There are three steps to add SwiftTweaks to your project:

1.  Create a `TweakLibraryType`, which contains a set of `Tweak`s and a `TweakStore` to persist them.
2.  Reference that `TweakLibraryType` in your code to use a `Tweak`.
3.  In your AppDelegate, make the `TweakWindow` the window of your app (there are other options, but this is the most straightforward! More on that later.)

Now build-and-run, then shake your phone to bring up the Tweaks UI! Adjust tweaks, and when you’re satisfied with what you’ve got, share your tweaks with others from within the Tweaks UI.

### Step One: Make your TweakLibrary

A tweak library is responsible for listing out a bunch of `public static` tweaks, and building a `TweakStore`. A tweak library looks like this:

```swift
public struct ExampleTweaks: TweakLibraryType {
	public static let colorTint = Tweak("General", "Colors", "Tint", UIColor.blue)
	public static let marginHorizontal = Tweak<CGFloat>("General", "Layout", "H. Margins", defaultValue: 15, min: 0)
	public static let marginVertical = Tweak<CGFloat>("General", "Layout", "V. Margins", defaultValue: 10, min: 0)
	public static let font = Tweak<StringOption>("General", "Layout", "Font", options: ["AvenirNext", "Helvetica", "SanFrancisco"])
	public static let featureFlagMainScreenHelperText = Tweak<Bool>("Feature Flags", "Main Screen", "Show Body Text", true)

	public static let buttonAnimation = SpringAnimationTweakTemplate("Animation", "Button Animation")

	public static let defaultStore: TweakStore = {
		let allTweaks: [TweakClusterType] = [colorTint, marginHorizontal, marginVertical, featureFlagMainScreenHelperText, buttonAnimation]

		let tweaksEnabled = TweakDebug.isActive

		return TweakStore(
			tweaks: allTweaks,
			enabled: tweaksEnabled
		)
	}()
}
```

Let’s break down what happened here:

- We have five tweaks in `ExampleTweaks`: a tint color, two `CGFloat`s for layout, a `StringOption` for font choice, and a `Bool` that toggles an in-development feature.
- The compiler can get confused between `Int`, `CGFloat`, and `Double` - so you might find it necessary to tell the `Tweak<T>` what type its `T` is - as we do here with our margin tweaks.
- We create a `defaultStore` by creating a `TweakStore`, which needs to know whether tweaks are `enabled`, and a list of all `tweaks`.
- The `enabled` flag on `TweakStore` exists so that `SwiftTweaks` isn’t accessible by your users in production. You can set it however you like; we enjoy using the `DEBUG` flag from our project’s Build Settings.

### Step Two: Using Your TweakLibrary

To use a tweak, you replace a number or `UIColor`s in your code with a `Tweak` reference, like this:

Here’s our original code:

```swift
button.tintColor = UIColor.green
```

**assign** returns the current value of the tweak:

```swift
button.tintColor = ExampleTweaks.assign(ExampleTweaks.colorTint)
```

**bind** calls its closure immediately, and again each time the tweak changes:

```swift
ExampleTweaks.bind(ExampleTweaks.colorTint) { button.tintColor = $0 }
```

**bindMultiple** calls its closure immediately, and again each time any of its tweaks change:

```swift
// A "multipleBind" is called initially, and each time _any_ of the included tweaks change:
let tweaksToWatch: [TweakType] = [ExampleTweaks.marginHorizontal, ExampleTweaks.marginVertical]
ExampleTweaks.bindMultiple(tweaksToWatch) {
	let horizontal = ExampleTweaks.assign(ExampleTweaks.marginHorizontal)
	let vertical = ExampleTweaks.assign(ExampleTweaks.marginVertical)
	scrollView.contentInset = UIEdgeInsets(top: vertical, right: horizontal, bottom: vertical, left: horizontal)
}
```

For more examples, check out the example project’s `ViewController.swift` file.

### Step Three: Set TweakWindow as your Root View Controller

By default, SwiftTweaks uses a shake gesture to bring up the UI, but you can also use a custom gesture!

## Installation

#### [Carthage](https://github.com/carthage/carthage)

To add `SwiftTweaks` to your application, add it to your `Cartfile`:

```
github "Khan/SwiftTweaks"
```

In addition, add `-DDEBUG` to **Other Swift Flags** in your project's Build Settings for your _Debug_ configuration.

#### [CocoaPods](http://cocoapods.org/?q=SwiftTweaks)

```ruby
pod 'SwiftTweaks'

# Enable DEBUG flag in Swift for SwiftTweaks
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'SwiftTweaks'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDEBUG'
                end
            end
        end
    end
end
```

## FAQ

#### Do I _have_ to set TweakWindow as the root of my app?

Nope! Wherever/however you prefer, just create a `TweaksViewController` like so:

    let tweaksVC = TweaksViewController(tweakStore: ExampleTweaks.defaultStore, delegate: self)

#### Can I have multiple `TweakLibraryType`s in my app?

Sure! You’d initialize their `defaultStore`s with a unique `storeName` identifier, like so:

```swift
public struct FirstTweaksLibrary: TweakLibraryType {
	// ...

	public static let defaultStore: TweakStore = {
		let allTweaks: [TweakClusterType] = //...

		return TweakStore(
			tweaks: allTweaks,
			storeName: "FirstTweaksLibrary", 	// Here's the identifier
			enabled: tweaksEnabled
		)
	}()
}
```

#### Why can’t any type be used for a `Tweak`?

While `Tweak<T>` is generic, we have to restrict `T` to be `TweakableType` so that we can guarantee that each kind of `T` can be represented in our editing interface and persisted on disk. More types would be awesome, though! It’d be neat to support dictionaries, closures, and other things.

If you’d like to extend `TweakableType`, you’ll need to extend some internal components, like `TweakViewDataType`, `TweakDefaultData`, `TweakViewData`, and `TweakPersistency`. Feel free to open a pull request if you’d like to add a new type!

#### How do I create a new TweakGroupTemplate?

Maybe you’re using a different animation framework, or want a template for `CGRect` or something like that - great! As long as the tweakable “components” of your template conform to `TweakableType` then you’re all set. Create a new `TweakGroupTemplateType`, and take a look at the existing templates for implementation suggestions. (You’ll probably want to use `SignedNumberTweakDefaultParameters` too - they’re very helpful!)

If you think your `TweakGroupTemplateType` would help out others, please make a pull request!
