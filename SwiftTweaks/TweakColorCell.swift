//
//  TweakSliderCell.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweakColorCellDelegate {
	func tweakColorCellDidChangeValue(cell: TweakColorCell)
}

/// a UITableViewCell that contains a slider & text field for editing a ColorComponent.
internal final class TweakColorCell: UITableViewCell {
	internal static let cellHeight: CGFloat = 50

	internal var delegate: TweakColorCellDelegate?

	internal var viewData: ColorComponent? {
		didSet {
			updateSubviews()
		}
	}

	private let slider = UISlider()
	private let label: UILabel = {
		let label = UILabel()
		label.textAlignment = .Right
		label.textColor = UIColor.lightGrayColor()
		return label
	}()
	private let textField: UITextField = {
		let textField = UITextField()
		textField.textAlignment = .Right
		textField.returnKeyType = .Done
		return textField
	}()
	private let accessory = UIView()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Value1, reuseIdentifier: reuseIdentifier)

		slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), forControlEvents: .ValueChanged)

		textField.delegate = self

		accessory.addSubview(slider)
		accessory.addSubview(textField)
		accessory.addSubview(label)
		accessoryView = accessory
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

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
		case .HexComponent:
			let textFieldFrame = CGRect(origin: CGPointZero, size: CGSize(width: bounds.width * 0.5, height: bounds.height))
			textField.frame = textFieldFrame
			accessory.bounds = CGRectIntegral(textFieldFrame)
		case .NumericalComponent:
			let sliderFrame = CGRect(
				origin: CGPointZero,
				size: CGSize(width: bounds.width - 130, height: bounds.height))
			let labelFrame = CGRect(
				origin: CGPoint(x: sliderFrame.width, y: 0),
				size: CGSize(width: 50, height: bounds.height))
			slider.frame = sliderFrame
			label.frame = labelFrame

			let accessoryFrame = CGRectUnion(sliderFrame, labelFrame)
			accessory.bounds = accessoryFrame
		}
	}

	private func updateSubviews() {
		// No point in setting data if we don't have it.
		guard let viewData = viewData else {
			return
		}

		textLabel?.text = viewData.title

		switch viewData {
		case .HexComponent(let hexString):
			slider.hidden = true
			label.hidden = true
			textField.hidden = false

			textField.textColor = tintColor
			textField.text = hexString
		case .NumericalComponent(let numberComponent):
			slider.hidden = false
			label.hidden = false
			textField.hidden = true

			slider.minimumValue = numberComponent.type.minimumValue
			slider.maximumValue = numberComponent.type.maximumValue
			slider.value = numberComponent.value
			slider.tintColor = numberComponent.type.tintColor ?? tintColor

			let numberFormatter = NSNumberFormatter()
			numberFormatter.numberStyle = .DecimalStyle
			numberFormatter.minimumFractionDigits = numberComponent.type.roundsToInteger ? 0 : 2
			numberFormatter.maximumFractionDigits = numberComponent.type.roundsToInteger ? 0 : 2
			numberFormatter.minimumIntegerDigits = 1
			label.text = numberFormatter.stringFromNumber(numberComponent.value)
		}
	}

	// MARK: Events
	@objc private func sliderValueChanged(sender: UISlider) {
		switch viewData! {
		case .NumericalComponent(let oldValue):
			let newValue = ColorComponentNumerical(type: oldValue.type, value: slider.value)
			viewData = .NumericalComponent(newValue)
			delegate?.tweakColorCellDidChangeValue(self)
		case .HexComponent:
			assertionFailure("Shouldn't be able to change slider if viewData.type != NumericalComponent")
			break
		}
	}
}

extension TweakColorCell: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(textField: UITextField) {
		if let text = textField.text, newValue = UIColor.colorWithHexString(text) {
			viewData = .HexComponent(newValue.hexString)
			delegate?.tweakColorCellDidChangeValue(self)
		} else {
			updateSubviews()
		}
	}
}
