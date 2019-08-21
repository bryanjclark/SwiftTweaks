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
	func tweakCellDidChangeCurrentValue(_ tweakCell: TweakTableCell)
}

/// A UITableViewCell that represents a single Tweak<T> in our UI.
internal final class TweakTableCell: UITableViewCell {
	internal weak var delegate: TweakTableCellDelegate?

	internal var viewData: TweakViewData? {
		didSet {
			accessoryView = accessory
			accessoryType = .none
			detailTextLabel?.text = nil
			selectionStyle = .none

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
		textField.textAlignment = .right
		textField.returnKeyType = .done
		textField.adjustsFontSizeToFitWidth = true
		textField.minimumFontSize = 12
		return textField
	}()
	private let disclosureArrow: UIImageView = {
		let disclosureArrowImage = UIImage(swiftTweaksImage: .disclosureIndicator)
		let imageView = UIImageView(image: disclosureArrowImage.withRenderingMode(.alwaysTemplate))
		imageView.contentMode = .center
		imageView.tintColor = AppTheme.Colors.controlSecondary
		return imageView
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)

		[switchControl, stepperControl, colorChit, textField, disclosureArrow].forEach { accessory.addSubview($0) }

		switchControl.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
		stepperControl.addTarget(self, action: #selector(self.stepperChanged(_:)), for: .valueChanged)
		textField.delegate = self

		detailTextLabel!.textColor = AppTheme.Colors.textPrimary
        
		let touchHighlightView = UIView()
		touchHighlightView.backgroundColor = AppTheme.Colors.tableCellTouchHighlight
		self.selectedBackgroundView = touchHighlightView
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static let numberTextWidthFraction: CGFloat = 0.25 // The fraction of the cell's width used for the text field
	private static let colorTextWidthFraction: CGFloat = 0.30
	private static let stringTextWidthFraction: CGFloat = 0.60
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
		case .boolean:
			switchControl.sizeToFit()
			accessory.bounds = switchControl.bounds

		case .integer, .int8, .int16, .int32, .int64, .uInt8, .uInt16, .uInt32, .uInt64, .float, .doubleTweak:
			stepperControl.sizeToFit()

			let textFrame = CGRect(
				origin: CGPoint.zero,
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

			let accessoryFrame = textFrame.union(stepperControlFrame)
			accessory.bounds = accessoryFrame.integral

		case .color:
			let textFrame = CGRect(
				origin: CGPoint.zero,
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

			let accessoryFrame = colorControlFrame.union(textFrame).union(disclosureArrowFrame)
			accessory.bounds = accessoryFrame.integral

		case .string:
			let textFrame = CGRect(
				origin: .zero,
				size: CGSize(
					width: bounds.width * TweakTableCell.stringTextWidthFraction,
					height: bounds.height
				)
			).integral
			textField.frame = textFrame
			accessory.bounds = textField.bounds

		case .date:
			let textFieldFrame = CGRect(
				origin: .zero,
				size: CGSize(
					width: bounds.width * TweakTableCell.stringTextWidthFraction,
					height: bounds.height
				)
			).integral
			textField.frame = textFieldFrame
			accessory.bounds = textField.bounds
			let disclosureArrowFrame = CGRect(
				origin: CGPoint(x: textFieldFrame.width + TweakTableCell.horizontalPadding, y: 0),
				size: CGSize(width: disclosureArrow.bounds.width, height: bounds.height)
			)
			disclosureArrow.frame = disclosureArrowFrame
			accessory.bounds = textFieldFrame.union(disclosureArrowFrame).integral

		case .stringList:
			let textFieldFrame = CGRect(
				origin: .zero,
				size: CGSize(
					width: bounds.width * TweakTableCell.stringTextWidthFraction,
					height: bounds.height
				)
			).integral
			textField.frame = textFieldFrame
			accessory.bounds = textField.bounds
			let disclosureArrowFrame = CGRect(
				origin: CGPoint(x: textFieldFrame.width + TweakTableCell.horizontalPadding, y: 0),
				size: CGSize(width: disclosureArrow.bounds.width, height: bounds.height)
			)
			disclosureArrow.frame = disclosureArrowFrame
			accessory.bounds = textFieldFrame.union(disclosureArrowFrame).integral

		case .action:
			accessory.bounds = .zero
		}
	}

	fileprivate func updateSubviews() {
		defer { self.setNeedsLayout() }

		guard let viewData = viewData else {
			switchControl.isHidden = true
			textField.isHidden = true
			stepperControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			return
		}

		// Show / hide views depending on viewData
		switch viewData {
		case .boolean:
			switchControl.isHidden = false
			textField.isHidden = true
			stepperControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			selectionStyle = .none
		case .integer, .int8, .int16, .int32, .int64, .uInt8, .uInt16, .uInt32, .uInt64, .float, .doubleTweak:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = false
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			selectionStyle = .default
		case .color:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = true
			colorChit.isHidden = false
			disclosureArrow.isHidden = false
			selectionStyle = .default
		case .string:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			selectionStyle = .default
		case .date:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = false
			selectionStyle = .default
		case .action:
			switchControl.isHidden = true
			textField.isHidden = true
			stepperControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
			selectionStyle = .default
		case .stringList:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = true
			colorChit.isHidden = true
			disclosureArrow.isHidden = false
			selectionStyle = .default
		}

		// For action tweaks, we tint the cell's text label
		switch viewData {
		case .action:
			self.textLabel?.textColor = AppTheme.Colors.controlTinted
			self.textLabel?.highlightedTextColor = AppTheme.Colors.controlTintedPressed
		default:
			self.textLabel?.textColor = AppTheme.Colors.textPrimary
			self.textLabel?.highlightedTextColor = nil
		}

		// Update accessory internals based on viewData
		var textFieldEnabled: Bool
		switch viewData {
		case let .boolean(value: value, _):
			switchControl.isOn = value
			textFieldEnabled = false

		case .integer, .int8, .int16, .int32, .int64, .uInt8, .uInt16, .uInt32, .uInt64:
			let doubleValue = viewData.doubleValue!
			self.updateStepper(value: doubleValue, stepperValues: viewData.stepperValues!)

			textField.text = String(describing: viewData.value)
			textField.keyboardType = .numberPad
			textFieldEnabled = true

		case .float, .doubleTweak:
			let doubleValue = viewData.doubleValue!
			self.updateStepper(value: doubleValue, stepperValues: viewData.stepperValues!)

			textField.text = doubleValue.stringValueRoundedToNearest(.thousandth)
			textField.keyboardType = .decimalPad
			textFieldEnabled = true

		case let .color(value: value, _):
			colorChit.backgroundColor = value
			textField.text = value.hexString
			textFieldEnabled = false

		case let .string(value, _):
			textField.text = value
			textField.placeholder = NSLocalizedString("Tap to edit", comment: "Text field placeholder for editable text")
			textField.keyboardType = .default
			textFieldEnabled = true

		case let .date(value, _):
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.timeStyle = .short
			textField.text = dateFormatter.string(from: value)

			textFieldEnabled = false

		case let .stringList(value: value, _, options: _):
			textField.text = value.value
			textFieldEnabled = false
		case .action:
			textFieldEnabled = false
		}

		textFieldEnabled = textFieldEnabled && !self.isInFloatingTweakGroupWindow

		textField.isUserInteractionEnabled = textFieldEnabled
		textField.textColor = textFieldEnabled ? AppTheme.Colors.textPrimary : AppTheme.Colors.controlSecondary
	}

	private func updateStepper(value: Double, stepperValues: TweakViewData.StepperValues) {
		stepperControl.minimumValue = stepperValues.stepperMin
		stepperControl.maximumValue = stepperValues.stepperMax
		stepperControl.stepValue = stepperValues.stepSize
		stepperControl.value = value // need to set this *after* the min/max have been set, else UIKit clips it.
	}

	/// Makes the text field active, bringing up the keyboard.
	/// NOTE: If the cell is in a FloatingTweakWindow, this does nothing.
	public func startEditingTextField() {
		self.textField.becomeFirstResponder()
	}


	// MARK: Events

	@objc private func switchChanged(_ sender: UISwitch) {
		switch viewData! {
		case let .boolean(_, defaultValue: defaultValue):
			viewData = .boolean(value: switchControl.isOn, defaultValue: defaultValue)
			delegate?.tweakCellDidChangeCurrentValue(self)
		default:
			assertionFailure("Shouldn't be able to toggle switch if view data isn't Boolean type")
		}
	}

	@objc private func stepperChanged(_ sender: UIStepper) {
		switch viewData! {
		case let .integer(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .integer, value: Int(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .int8(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .int8, value: Int8(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .int16(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .int16, value: Int16(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .int32(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .int32, value: Int32(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .int64(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .int64, value: Int64(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .uInt8(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .uInt8, value: UInt8(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .uInt16(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .uInt16, value: UInt16(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .uInt32(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .uInt32, value: UInt32(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .uInt64(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .uInt64, value: UInt64(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .float(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .cgFloat, value: CGFloat(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .doubleTweak(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .double, value: stepperControl.value, defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case .color, .boolean, .action, .stringList, .string, .date:
			assertionFailure("Shouldn't be able to update text field with a Color/Boolean/Action/StringList/String tweak.")
		}
	}
}

extension TweakTableCell: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return !isInFloatingTweakGroupWindow
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		switch viewData! {
		case let .integer(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Int(text) {
				viewData = TweakViewData(type: .integer, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .int8(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Int8(text) {
				viewData = TweakViewData(type: .int8, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .int16(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Int16(text) {
				viewData = TweakViewData(type: .int16, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .int32(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Int32(text) {
				viewData = TweakViewData(type: .int32, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .int64(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Int64(text) {
				viewData = TweakViewData(type: .int64, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .uInt8(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = UInt8(text) {
				viewData = TweakViewData(type: .uInt8, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .uInt16(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = UInt16(text) {
				viewData = TweakViewData(type: .uInt16, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .uInt32(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = UInt32(text) {
				viewData = TweakViewData(type: .uInt32, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .uInt64(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = UInt64(text) {
				viewData = TweakViewData(type: .uInt64, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .float(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Float(text) {
				viewData = TweakViewData(type: .cgFloat, value: CGFloat(newValue), defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .doubleTweak(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Double(text) {
				viewData = TweakViewData(type: .double, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .color(_, defaultValue: defaultValue):
			if let text = textField.text, let newValue = UIColor.colorWithHexString(text) {
				viewData = TweakViewData(type: .uiColor, value: newValue, defaultValue: defaultValue, minimum: nil, maximum: nil, stepSize: nil, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .string(_, defaultValue):
			if let newValue = textField.text {
				viewData = TweakViewData(type: .string, value: newValue, defaultValue: defaultValue, minimum: nil, maximum: nil, stepSize: nil, options: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case .boolean, .action, .stringList, .date:
			assertionFailure("Shouldn't be able to update text field with a Boolean/Action/StringList tweak.")
		}
	}
}
