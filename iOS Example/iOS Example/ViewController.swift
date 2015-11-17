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

		ExampleTweaks.bind(ExampleTweaks.titleScreenShowHelperText) { self.bodyLabel.hidden = !$0 }

	}

	override func viewWillAppear(animated: Bool) {
		view.backgroundColor = ExampleTweaks.assign(ExampleTweaks.colorBackground)

		titleLabel.textColor = ExampleTweaks.assign(ExampleTweaks.colorText1)
		titleLabel.font = UIFont.systemFontOfSize(ExampleTweaks.assign(ExampleTweaks.fontSizeText1))
		titleLabel.sizeToFit()
		titleLabel.frame = CGRect(origin: CGPoint(x: 0, y: 30), size: CGSizeMake(view.bounds.width, titleLabel.frame.height))

//		bodyLabel.hidden = !ExampleTweaks.assign(ExampleTweaks.titleScreenShowHelperText)
		bodyLabel.textColor = ExampleTweaks.assign(ExampleTweaks.colorText2)
		bodyLabel.font = UIFont.systemFontOfSize(ExampleTweaks.assign(ExampleTweaks.fontSizeText2))
		bodyLabel.frame = CGRect(
			origin: CGPoint(x: ExampleTweaks.assign(ExampleTweaks.horizontalMargins), y: CGRectGetMaxY(titleLabel.frame) + ExampleTweaks.assign(ExampleTweaks.titleScreenGapBetweenTitleAndBody)),
			size: bodyLabel.sizeThatFits(CGSize(width: view.bounds.width - ExampleTweaks.assign(ExampleTweaks.horizontalMargins)*2, height: CGFloat.max)))
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}