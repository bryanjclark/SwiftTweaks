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
	private static let stringListValueLeadingPadding: CGFloat = 10 // Leading padding before the string list's value text field
	private static let stringListTitleMaxWidthFraction: CGFloat = 0.7 // Maximum percent of the available space that the title can use when truncating the value
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

		case .integer, .float, .doubleTweak:
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

		case .stringList:
			let textFieldFrame = computeStringListTextFieldFrame()
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
	
	// For stringList, in most cases we want to give the title's content precedence over the value,
	// such that the value will scale down in the available space, and then truncate. However,
	// for a very long title, limit the title to a fixed percentage of the cell's width.
	fileprivate func computeStringListTextFieldFrame() -> CGRect {
		guard let textLabel = textLabel else { return bounds }
		
		// Compute total width available for text
		let fittingSize = CGSize(
			width: CGFloat.greatestFiniteMagnitude,
			height: bounds.height
		)
		let titleLeadingSystemPadding: CGFloat = 15.0
		let accessoryTrailingSystemPadding: CGFloat = 15.0
		let spaceAfterTextField = TweakTableCell.horizontalPadding + disclosureArrow.bounds.width + accessoryTrailingSystemPadding
		let availableContentWidth = bounds.width - titleLeadingSystemPadding - TweakTableCell.stringListValueLeadingPadding - spaceAfterTextField
		
		// Compute percent of available width used for title at default size.
		let titleContentSize = textLabel.sizeThatFits(fittingSize)
		let titleContentPercent = ceil(titleContentSize.width / availableContentWidth)
		
		// Compute percent of available width used for value at default size.
		let textFieldContentWidth = self.textField.sizeThatFits(fittingSize).width + TweakTableCell.stringListValueLeadingPadding
		let textFieldContentPercent = textFieldContentWidth / availableContentWidth
		
		// Compute the default width for the text field: fill the available space left after the title
		let textFieldAvailablePercent = 1.0 - titleContentPercent
		var textFieldWidth = textFieldAvailablePercent * availableContentWidth

		// Compute actual width for the textField.
		let titleMaxWidthPercent = TweakTableCell.stringListTitleMaxWidthFraction
		let allContentPercent = titleContentPercent + textFieldContentPercent
		
		// If the title is longer than the overflow threshhold, and the value is long enough that it would need to be scaled down,
		// then let the text field have as much space as it wants, up to the `TweakTableCell.stringListTitleMaxWidthFraction` amount.
		if titleContentPercent > titleMaxWidthPercent && allContentPercent > 1.0 {
			let textFieldGuaranteedAvailableWidth = (1.0 - titleMaxWidthPercent) * availableContentWidth
			let textFieldDesiredWidth = textFieldContentWidth
			textFieldWidth = min(textFieldGuaranteedAvailableWidth, textFieldDesiredWidth)
		}
		
		return CGRect(
			origin: .zero,
			size: CGSize(
				width: textFieldWidth,
				height: bounds.height
			)
		).integral
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
		case .integer, .float, .doubleTweak:
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

		case .integer:
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
		case let .float(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .cgFloat, value: CGFloat(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .doubleTweak(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .double, value: stepperControl.value, defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step, options: nil)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case .color, .boolean, .action, .stringList, .string:
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
		case .boolean, .action, .stringList:
			assertionFailure("Shouldn't be able to update text field with a Boolean/Action/StringList tweak.")
		}
	}
}
