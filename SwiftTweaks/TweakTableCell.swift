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
	internal var delegate: TweakTableCellDelegate?

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
				colorChit.hidden = true
				return
			}

			// Show / hide views depending on viewData
			switch viewData {
			case .Boolean:
				switchControl.hidden = false
				textField.hidden = true
				stepperControl.hidden = true
				colorChit.hidden = true
			case .Integer, .Float:
				switchControl.hidden = true
				textField.hidden = false
				stepperControl.hidden = false
				colorChit.hidden = true
			case .Color:
				switchControl.hidden = true
				textField.hidden = false
				stepperControl.hidden = true
				colorChit.hidden = false
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
				colorChit.backgroundColor = value
				textField.text = value.hexString
			}
		}
	}
	private var accessory = UIView()
	private var switchControl = UISwitch()
	private var stepperControl = UIStepper()
	private var colorChit: UIView = {
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

		[switchControl, stepperControl, colorChit, textField].forEach { accessory.addSubview($0) }

		switchControl.addTarget(self, action: "switchChanged:", forControlEvents: .ValueChanged)
		stepperControl.addTarget(self, action: "stepperChanged:", forControlEvents: .ValueChanged)
		textField.delegate = self

		detailTextLabel?.textColor = UIColor.blackColor()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static let numberTextWidthFraction: CGFloat = 0.25 // The fraction of the cell's width used for the text field
	private static let colorTextWidthFraction: CGFloat = 0.30
	private static let horizontalPadding: CGFloat = 6 // Horiz. separation between stepper and text field
	private static let colorChitSize = CGSize(width: 29, height: 29)

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
			let textWidth = bounds.width * TweakTableCell.numberTextWidthFraction
			let (textFrame, stepperControlFrame) = layoutFramesForTextFieldAndControlWithControlSize(stepperControl.bounds.size, textFieldWidth: textWidth)
			textField.frame = textFrame
			stepperControl.frame = stepperControlFrame

			let accessoryFrame = CGRectUnion(textFrame, stepperControlFrame)
			accessory.bounds = CGRectIntegral(accessoryFrame)
		case .Color:
			let textWidth = bounds.width * TweakTableCell.colorTextWidthFraction
			let (textFrame, colorControlFrame) = layoutFramesForTextFieldAndControlWithControlSize(TweakTableCell.colorChitSize, textFieldWidth: textWidth)
			textField.frame = textFrame
			colorChit.frame = colorControlFrame

			let accessoryFrame = CGRectUnion(colorControlFrame, textFrame)
			accessory.bounds = CGRectIntegral(accessoryFrame)
		}
	}

	private func layoutFramesForTextFieldAndControlWithControlSize(controlSize: CGSize, textFieldWidth: CGFloat) -> (textFrame: CGRect, controlFrame: CGRect) {
		let textFrame = CGRect(
			origin: CGPointZero,
			size: CGSize(
				width: textFieldWidth,
				height: bounds.height
			)
		)

		let controlFrame = CGRect(
			origin: CGPoint(
				x: textFrame.width + TweakTableCell.horizontalPadding,
				y: (textFrame.height - controlSize.height) / 2
			),
			size: controlSize
		)

		return (textFrame, controlFrame)
	}

	// MARK: Events
	@objc private func switchChanged(sender: UISwitch) {
		switch viewData! {
		case let .Boolean(value: _, defaultValue: defaultValue):
			viewData = .Boolean(value: switchControl.on, defaultValue: defaultValue)
			delegate?.tweakCellDidChangeCurrentValue(self)
		default:
			assertionFailure("Shouldn't be able to toggle switch if view data isn't Boolean type")
		}
	}

	@objc private func stepperChanged(sender: UIStepper) {
		switch viewData! {
		case let .Integer(value: _, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = .Integer(value: Int(stepperControl.value), defaultValue: defaultValue, min: min, max: max, stepSize: step)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .Float(value: _, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = .Float(value: CGFloat(stepperControl.value), defaultValue: defaultValue, min: min, max: max, stepSize: step)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case .Color, .Boolean:
			assertionFailure("Shouldn't be able to update text field with a Color or Boolean tweak.")
		}
	}
}

extension TweakTableCell: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(textField: UITextField) {
		switch viewData! {
		case let .Integer(value: _, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			if let text = textField.text, newValue = Int(text) {
				viewData = .Integer(value: newValue, defaultValue: defaultValue, min: min, max: max, stepSize: step)
				delegate?.tweakCellDidChangeCurrentValue(self)
			}
		case let .Float(value: _, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			if let text = textField.text, newValue = Float(text) {
				viewData = .Float(value: CGFloat(newValue), defaultValue: defaultValue, min: min, max: max, stepSize: step)
				delegate?.tweakCellDidChangeCurrentValue(self)
			}
		case let .Color(value: _, defaultValue: defaultValue):
			if let text = textField.text, newValue = UIColor(hexString: text) {
				viewData = .Color(value: newValue, defaultValue: defaultValue)
				delegate?.tweakCellDidChangeCurrentValue(self)
			}
		case .Boolean:
			assertionFailure("Shouldn't be able to update text field with a Boolean tweak.")
		}
	}
}