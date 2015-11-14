//
//  TweakTableCell.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/13/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

internal protocol TweakTableCellDelegate {
	func tweakCellDidChangeCurrentValue(tweakCell: TweakTableCell)
}


internal class TweakTableCell: UITableViewCell {
	internal var viewData: TweakViewData? {
		didSet {
			accessoryView = accessory
			accessoryType = .None
			detailTextLabel?.text = nil
			selectionStyle = .None

			defer {
				setNeedsLayout()
				layoutIfNeeded()
			}

			guard let viewData = viewData else {
				switchControl.hidden = true
				textField.hidden = true
				stepperControl.hidden = true
				colorControl.hidden = true
				return
			}

			// Show / hide views depending on viewData
			switch viewData {
			case .Boolean:
				switchControl.hidden = false
				textField.hidden = true
				stepperControl.hidden = true
				colorControl.hidden = true
			case .Integer, .Float:
				switchControl.hidden = true
				textField.hidden = false
				stepperControl.hidden = false
				colorControl.hidden = true
			case .Color:
				switchControl.hidden = true
				textField.hidden = true
				stepperControl.hidden = true
				colorControl.hidden = false
			}

			// Update accessory internals based on viewData
			switch viewData {
			case let .Boolean(value: value, defaultValue: _):
				switchControl.on = value
			case let .Integer(value: value, defaultValue: _, min: min, max: max, stepSize: step):
				stepperControl.value = Double(value)
				stepperControl.minimumValue = Double(min ?? 0)
				stepperControl.maximumValue = Double(max ?? 100)
				stepperControl.stepValue = Double(step ?? (stepperControl.maximumValue - stepperControl.minimumValue)/100)

				textField.text = String(value)
				textField.keyboardType = .NumberPad
			case let .Float(value: value, defaultValue: defaultValue, min: min, max: max, stepSize: step):
				stepperControl.value = Double(value)
				stepperControl.minimumValue = Double(min ?? defaultValue / 10)
				stepperControl.maximumValue = Double(max ?? defaultValue * 10)
				stepperControl.stepValue = Double(step ?? (stepperControl.maximumValue - stepperControl.minimumValue)/100)

				textField.text = String(value)
				textField.keyboardType = .DecimalPad
			case let .Color(value: value, defaultValue: _):
				colorControl.backgroundColor = value
			}
		}
	}

	private var accessory = UIView()
	private var switchControl = UISwitch()
	private var stepperControl = UIStepper()
	private var colorControl: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 4
		return view
	}()
	private var textField: UITextField = {
		let textField = UITextField()
		textField.textAlignment = .Right
		return textField
	}()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Value1, reuseIdentifier: reuseIdentifier)

		[switchControl, stepperControl, colorControl, textField].forEach { accessory.addSubview($0) }
		detailTextLabel?.textColor = UIColor.blackColor()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static let detailTextLabelFraction: CGFloat = 0.20 // The fraction of the cell's width used for the text field
	private static let horizontalPadding: CGFloat = 6 // Horiz. separation between stepper and text field
	private static let colorControlSize = CGSize(width: 29, height: 29)

	override func layoutSubviews() {

		defer {
			// After adjusting the accessoryView's frame, we need to call super.layoutSubviews()
			super.layoutSubviews()
		}

		// No need to proceed if we don't have view data
		guard let viewData = viewData else {
			return
		}

		switch viewData {
		case .Boolean:
			switchControl.sizeToFit()
			accessory.bounds = switchControl.bounds
		case .Integer, .Float:
			stepperControl.sizeToFit()
			let textFrame = CGRect(
				origin: CGPointZero,
				size: CGSize(
					width: bounds.width * TweakTableCell.detailTextLabelFraction,
					height: bounds.height
				)
			)
			let stepperFrame = CGRect(
				x: textFrame.width + TweakTableCell.horizontalPadding,
				y: (textFrame.height - stepperControl.bounds.height) / 2,
				width: stepperControl.bounds.width,
				height: stepperControl.bounds.height)
			textField.frame = textFrame
			stepperControl.frame = stepperFrame

			let accessoryFrame = CGRectUnion(stepperFrame, textFrame)
			accessory.bounds = CGRectIntegral(accessoryFrame)
		case .Color:
			colorControl.frame = CGRect(origin: CGPointZero, size: TweakTableCell.colorControlSize)
			accessory.bounds = colorControl.bounds
		}
	}

	// MARK: Events
	@objc private func switchChanged(sender: UISwitch) {
		// updateValue(switch.on, primary: false, write: true)
	}

	@objc private func stepperChanged(sender: UIStepper) {
		// updateValue(sender.value, primary: false, write: true)
	}
}