//
//  TweakSliderCell.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/16/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweakColorCellDelegate: class {
	func tweakColorCellDidChangeValue(_ cell: TweakColorCell)
}

/// a UITableViewCell that contains a slider & text field for editing a ColorComponent.
internal final class TweakColorCell: UITableViewCell {
	internal static let cellHeight: CGFloat = 50

	internal unowned var delegate: TweakColorCellDelegate?

	internal var viewData: ColorComponent? {
		didSet {
			updateSubviews()
		}
	}

	private let slider = UISlider()
	private let label: UILabel = {
		let label = UILabel()
		label.textAlignment = .right
		if #available(iOS 13.0, *) {
			label.textColor = UIColor.secondaryLabel
		} else {
			label.textColor = UIColor.lightGray
		}
		return label
	}()
	private let textField: UITextField = {
		let textField = UITextField()
		textField.textAlignment = .right
		textField.returnKeyType = .done
		return textField
	}()
	private let accessory = UIView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)

		slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)

		textField.delegate = self

		let touchHighlightView = UIView()
		touchHighlightView.backgroundColor = AppTheme.Colors.tableCellTouchHighlight
		self.selectedBackgroundView = touchHighlightView

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
		case .hexComponent:
			let textFieldFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width * 0.5, height: bounds.height))
			textField.frame = textFieldFrame
			accessory.bounds = textFieldFrame.integral
		case .numericalComponent:
			let sliderFrame = CGRect(
				origin: CGPoint.zero,
				size: CGSize(width: bounds.width - 130, height: bounds.height))
			let labelFrame = CGRect(
				origin: CGPoint(x: sliderFrame.width, y: 0),
				size: CGSize(width: 50, height: bounds.height))
			slider.frame = sliderFrame
			label.frame = labelFrame

			let accessoryFrame = sliderFrame.union(labelFrame)
			accessory.bounds = accessoryFrame
		}
	}

	fileprivate func updateSubviews() {
		// No point in setting data if we don't have it.
		guard let viewData = viewData else {
			return
		}

		textLabel?.text = viewData.title

		switch viewData {
		case .hexComponent(let hexString):
			slider.isHidden = true
			label.isHidden = true
			textField.isHidden = false

			textField.textColor = tintColor
			textField.text = hexString
		case .numericalComponent(let numberComponent):
			slider.isHidden = false
			label.isHidden = false
			textField.isHidden = true

			slider.minimumValue = numberComponent.type.minimumValue
			slider.maximumValue = numberComponent.type.maximumValue
			slider.value = numberComponent.value
			slider.tintColor = numberComponent.type.tintColor ?? tintColor

			let numberFormatter = NumberFormatter()
			numberFormatter.numberStyle = .decimal
			numberFormatter.minimumFractionDigits = numberComponent.type.roundsToInteger ? 0 : 2
			numberFormatter.maximumFractionDigits = numberComponent.type.roundsToInteger ? 0 : 2
			numberFormatter.minimumIntegerDigits = 1
            label.text = numberFormatter.string(from: NSNumber(value: numberComponent.value))
		}
	}

	// MARK: Events
	@objc private func sliderValueChanged(_ sender: UISlider) {
		switch viewData! {
		case .numericalComponent(let oldValue):
			let newValue = ColorComponentNumerical(type: oldValue.type, value: slider.value)
			viewData = .numericalComponent(newValue)
			delegate?.tweakColorCellDidChangeValue(self)
		case .hexComponent:
			assertionFailure("Shouldn't be able to change slider if viewData.type != NumericalComponent")
			break
		}
	}
}

extension TweakColorCell: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		if let text = textField.text, let newValue = UIColor.colorWithHexString(text) {
			viewData = .hexComponent(newValue.hexString)
			delegate?.tweakColorCellDidChangeValue(self)
		} else {
			updateSubviews()
		}
	}
}
