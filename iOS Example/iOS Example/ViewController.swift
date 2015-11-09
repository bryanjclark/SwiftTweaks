//
//  ViewController.swift
//  iOS Example
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = NSTextAlignment.Center
		label.textColor = ExampleTweaks.assign(ExampleTweaks.colorText1)
		label.text = "SwiftTweaks"
		label.font = UIFont.systemFontOfSize(ExampleTweaks.assign(ExampleTweaks.fontSizeText1))
		return label
	}()

	private let bodyLabel: UILabel = {
		let label = UILabel()
		label.textColor = ExampleTweaks.assign(ExampleTweaks.colorText2)
		label.text = "Shake your device to bring up the Tweaks UI."
		label.font = UIFont.systemFontOfSize(ExampleTweaks.assign(ExampleTweaks.fontSizeText2))
		return label
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = ExampleTweaks.assign(ExampleTweaks.colorBackground)

		titleLabel.sizeToFit()
		titleLabel.frame = CGRect(origin: CGPointZero, size: CGSizeMake(view.bounds.width, titleLabel.frame.height))
		view.addSubview(titleLabel)

		bodyLabel.sizeToFit()
		bodyLabel.frame = CGRect(origin: CGPoint(x: 0, y: CGRectGetMaxY(titleLabel.frame) + ExampleTweaks.assign(ExampleTweaks.titleScreenGapBetweenTitleAndBody)), size: CGSize(width: view.bounds.width, height: bodyLabel.bounds.height))
		view.addSubview(bodyLabel)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: Status Bar
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
}

