//
//  TweakTableCell.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/13/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit
import Foundation

internal protocol TweakTableCellDelegate: class {
	func tweakCellDidChangeCurrentValue(tweakCell: TweakTableCell)
}

/// A UITableViewCell that represents a single Tweak<T> in our UI.
internal final class TweakTableCell: UITableViewCell {
	internal weak var delegate: TweakTableCellDelegate?

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

			updateSubviews()
		}
	}

	internal var isInFloatingTweakGroupWindow = false

	private var accessory = UIView()

	private let switchControl: UISwitch = {
		let switchControl = UISwitch()
		switchControl.onTintColor = AppTheme.Colors.controlTinted
		switchControl.tintColor = AppTheme.Colors.controlDisabled
		return switchControl
	}()

	private let stepperControl: UIStepper = {
		let stepper = UIStepper()
		stepper.tintColor = AppTheme.Colors.controlTinted
		return stepper
	}()

	private let colorChit: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 4
		return view
	}()
	private let textField: UITextField = {
		let textField = UITextField()
		textField.textAlignment = .Right
		textField.returnKeyType = .Done
		return textField
	}()
	private let disclosureArrow: UIImageView = {
		let disclosureArrowImage = UIImage(swiftTweaksImage: .DisclosureIndicator)
		let imageView = UIImageView(image: disclosureArrowImage.imageWithRenderingMode(.AlwaysTemplate))
		imageView.contentMode = .Center
		imageView.tintColor = AppTheme.Colors.controlSecondary
		return imageView
	}()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Value1, reuseIdentifier: reuseIdentifier)

		[switchControl, stepperControl, colorChit, textField, disclosureArrow].forEach { accessory.addSubview($0) }

		switchControl.addTarget(self, action: #selector(self.switchChanged(_:)), forControlEvents: .ValueChanged)
		stepperControl.addTarget(self, action: #selector(self.stepperChanged(_:)), forControlEvents: .ValueChanged)
		textField.delegate = self

		detailTextLabel!.textColor = AppTheme.Colors.textPrimary
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
		case .Integer, .Float, .DoubleTweak:
			stepperControl.sizeToFit()

			let textFrame = CGRect(
				origin: CGPointZero,
				size: CGSize(
					width: bounds.width * TweakTableCell.numberTextWidthFraction,
					height: bounds.height
				)
			)

			let stepperControlFrame = CGRect(
				origin: CGPoint(
					x: textFrame.width + TweakTableCell.horizontalPadding,
					y: (textFrame.height - stepperControl.bounds.height) / 2
				),
				size: stepperControl.bounds.size
			)

			textField.frame = textFrame
			stepperControl.frame = stepperControlFrame

			let accessoryFrame = CGRectUnion(textFrame, stepperControlFrame)
			accessory.bounds = CGRectIntegral(accessoryFrame)
		case .Color:
			let textFrame = CGRect(
				origin: CGPointZero,
				size: CGSize(
					width: bounds.width * TweakTableCell.colorTextWidthFraction,
					height: bounds.height
				)
			)

			let colorControlFrame = CGRect(
				origin: CGPoint(
					x: textFrame.width + TweakTableCell.horizontalPadding,
					y: (textFrame.height - stepperControl.bounds.height) / 2
				),
				size: TweakTableCell.colorChitSize
			)

			let disclosureArrowFrame = CGRect(
				origin: CGPoint(
					x: textFrame.width + colorControlFrame.width + 2 * TweakTableCell.horizontalPadding,
					y: 0),
				size: CGSize(
					width: disclosureArrow.bounds.width,
					height: bounds.height
				)
			)

			textField.frame = textFrame
			colorChit.frame = colorControlFrame
			disclosureArrow.frame = disclosureArrowFrame

			let accessoryFrame = CGRectUnion(CGRectUnion(colorControlFrame, textFrame), disclosureArrowFrame)
			accessory.bounds = CGRectIntegral(accessoryFrame)
		}
	}

	private func updateSubviews() {
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
			disclosureArrow.hidden = true
		case .Integer, .Float, .DoubleTweak:
			switchControl.hidden = true
			textField.hidden = false
			stepperControl.hidden = false
			colorChit.hidden = true
			disclosureArrow.hidden = true
		case .Color:
			switchControl.hidden = true
			textField.hidden = false
			stepperControl.hidden = true
			colorChit.hidden = false
			disclosureArrow.hidden = false
		}

		// Update accessory internals based on viewData
		var textFieldEnabled: Bool
		switch viewData {
		case let .Boolean(value: value, _):
			switchControl.on = value
			textFieldEnabled = false

		case let .Integer(value: value, _, _, _, stepSize: step):
			stepperControl.value = Double(value)
			(stepperControl.minimumValue, stepperControl.maximumValue) = viewData.stepperLimits!
			stepperControl.stepValue = Double(step ?? 1)

			textField.text = String(value)
			textField.keyboardType = .NumberPad
			textFieldEnabled = true

		case let .Float(value: value, _, _, _, stepSize: step):
			stepperControl.value = Double(value)
			(stepperControl.minimumValue, stepperControl.maximumValue) = viewData.stepperLimits!
			stepperControl.stepValue = Double(step ?? (stepperControl.maximumValue - stepperControl.minimumValue)/100)

			textField.text = value.stringValueRoundedToNearest(.Thousandth)
			textField.keyboardType = .DecimalPad
			textFieldEnabled = true

		case let .DoubleTweak(value: value, _, _, _, stepSize: step):
			stepperControl.value = value
			(stepperControl.minimumValue, stepperControl.maximumValue) = viewData.stepperLimits!
			stepperControl.stepValue = step ?? (stepperControl.maximumValue - stepperControl.minimumValue)/100

			textField.text = value.stringValueRoundedToNearest(.Thousandth)
			textField.keyboardType = .DecimalPad
			textFieldEnabled = true

		case let .Color(value: value, _):
			colorChit.backgroundColor = value
			textField.text = value.hexString
			textFieldEnabled = false

		}

		textFieldEnabled = textFieldEnabled && !self.isInFloatingTweakGroupWindow

		textField.userInteractionEnabled = textFieldEnabled
		textField.textColor = textFieldEnabled ? AppTheme.Colors.textPrimary : AppTheme.Colors.controlSecondary

	}


	// MARK: Events

	@objc private func switchChanged(sender: UISwitch) {
		switch viewData! {
		case let .Boolean(_, defaultValue: defaultValue):
			viewData = .Boolean(value: switchControl.on, defaultValue: defaultValue)
			delegate?.tweakCellDidChangeCurrentValue(self)
		default:
			assertionFailure("Shouldn't be able to toggle switch if view data isn't Boolean type")
		}
	}

	@objc private func stepperChanged(sender: UIStepper) {
		switch viewData! {
		case let .Integer(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .Integer, value: Int(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .Float(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .CGFloat, value: CGFloat(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .DoubleTweak(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .Double, value: stepperControl.value, defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case .Color, .Boolean:
			assertionFailure("Shouldn't be able to update text field with a Color or Boolean tweak.")
		}
	}
}

extension TweakTableCell: UITextFieldDelegate {
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		return !isInFloatingTweakGroupWindow
	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(textField: UITextField) {
		switch viewData! {
		case let .Integer(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, newValue = Int(text) {
				viewData = TweakViewData(type: .Integer, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .Float(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, newValue = Float(text) {
				viewData = TweakViewData(type: .CGFloat, value: CGFloat(newValue), defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .DoubleTweak(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, newValue = Double(text) {
				viewData = TweakViewData(type: .Double, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .Color(_, defaultValue: defaultValue):
			if let text = textField.text, newValue = UIColor.colorWithHexString(text) {
				viewData = TweakViewData(type: .UIColor, value: newValue, defaultValue: defaultValue, minimum: nil, maximum: nil, stepSize: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case .Boolean:
			assertionFailure("Shouldn't be able to update text field with a Boolean tweak.")
		}
	}
}
