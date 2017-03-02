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
		textField.textAlignment = .right
		textField.returnKeyType = .done
		return textField
	}()
	private let disclosureArrow: UIImageView = {
		let disclosureArrowImage = UIImage(swiftTweaksImage: .disclosureIndicator)
		let imageView = UIImageView(image: disclosureArrowImage.withRenderingMode(.alwaysTemplate))
		imageView.contentMode = .center
		imageView.tintColor = AppTheme.Colors.controlSecondary
		return imageView
	}()
    
    private let optionsTextField: UITextField = {
        let optionsTextField = UITextField()
        optionsTextField.textAlignment = .right
        return optionsTextField
    }()
    
    private let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
    private let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private let optionsPickerView =  UIPickerView()
    private let optionsTextFieldToolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.tintColor = AppTheme.Colors.controlTinted
        toolBar.sizeToFit()
        return toolBar
    }()
    
    dynamic func selectedOption(sender: AnyObject) {
        switch viewData! {
        case let .optionsList(_, defaultValue: defaultValue, options: options):
            viewData = .optionsList(value: options[optionsPickerView.selectedRow(inComponent: 0)], defaultValue: defaultValue, options: options)
            delegate?.tweakCellDidChangeCurrentValue(self)
            optionsTextField.resignFirstResponder()
        default:
            assertionFailure("Shouldn't be triggered if view data isn't OptionsList type")
        }
    }

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)

		[switchControl, stepperControl, colorChit, textField, optionsTextField, disclosureArrow].forEach { accessory.addSubview($0) }

		switchControl.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
		stepperControl.addTarget(self, action: #selector(self.stepperChanged(_:)), for: .valueChanged)
		textField.delegate = self
        optionsPickerView.delegate = self
        optionsPickerView.dataSource = self
        
        doneButton.target = self
        doneButton.action = #selector(selectedOption(sender:))
        optionsTextFieldToolbar.setItems([spaceButton, doneButton], animated: false)
        optionsTextField.inputView = optionsPickerView
        optionsTextField.inputAccessoryView = optionsTextFieldToolbar

		detailTextLabel!.textColor = AppTheme.Colors.textPrimary
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static let numberTextWidthFraction: CGFloat = 0.25 // The fraction of the cell's width used for the text field
	private static let colorTextWidthFraction: CGFloat = 0.30
    private static let optionsListWidthFraction: CGFloat = 0.60
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
            optionsTextField.backgroundColor = .blue

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
        case .optionsList:
            let textFrame = CGRect(
                origin: CGPoint.zero,
                size: CGSize(
                    width: bounds.width * TweakTableCell.optionsListWidthFraction,
                    height: bounds.height
                )
            )
            optionsTextField.frame = textFrame
            accessory.bounds = optionsTextField.bounds
		}
	}

	fileprivate func updateSubviews() {
		guard let viewData = viewData else {
			switchControl.isHidden = true
			textField.isHidden = true
			stepperControl.isHidden = true
			colorChit.isHidden = true
            optionsTextField.isHidden = false
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
            optionsTextField.isHidden = false
		case .integer, .float, .doubleTweak:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = false
			colorChit.isHidden = true
			disclosureArrow.isHidden = true
            optionsTextField.isHidden = false
		case .color:
			switchControl.isHidden = true
			textField.isHidden = false
			stepperControl.isHidden = true
			colorChit.isHidden = false
			disclosureArrow.isHidden = false
            optionsTextField.isHidden = true
        case .optionsList:
            optionsTextField.isHidden = false
            switchControl.isHidden = true
            textField.isHidden = true
            stepperControl.isHidden = true
            colorChit.isHidden = true
            disclosureArrow.isHidden = true
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
        case let .optionsList(value: stringOption, _, _):
            optionsTextField.text = stringOption.value
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
			viewData = TweakViewData(type: .integer, value: Int(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .float(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .cgFloat, value: CGFloat(stepperControl.value), defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case let .doubleTweak(_, defaultValue: defaultValue, min: min, max: max, stepSize: step):
			viewData = TweakViewData(type: .double, value: stepperControl.value, defaultValue: defaultValue, minimum: min, maximum: max, stepSize: step)
			delegate?.tweakCellDidChangeCurrentValue(self)
		case .color, .boolean, .optionsList:
			assertionFailure("Shouldn't be able to update text field with a Color or Boolean tweak.")
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
				viewData = TweakViewData(type: .integer, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .float(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Float(text) {
				viewData = TweakViewData(type: .cgFloat, value: CGFloat(newValue), defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .doubleTweak(_, defaultValue: defaultValue, min: minimum, max: maximum, stepSize: step):
			if let text = textField.text, let newValue = Double(text) {
				viewData = TweakViewData(type: .double, value: newValue, defaultValue: defaultValue, minimum: minimum, maximum: maximum, stepSize: step)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case let .color(_, defaultValue: defaultValue):
			if let text = textField.text, let newValue = UIColor.colorWithHexString(text) {
				viewData = TweakViewData(type: .uiColor, value: newValue, defaultValue: defaultValue, minimum: nil, maximum: nil, stepSize: nil)
				delegate?.tweakCellDidChangeCurrentValue(self)
			} else {
				updateSubviews()
			}
		case .boolean, .optionsList:
			assertionFailure("Shouldn't be able to update text field with a Boolean tweak.")
		}
	}
}



extension TweakTableCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let viewData = viewData else { return 0 }
        switch viewData {
        case let .optionsList(_, _, options: options):
            return options.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let viewData = viewData else { return nil }
        switch viewData {
        case let .optionsList(_, _, options: options):
            return options[row].value
        default:
            return nil
        }
    }
}
