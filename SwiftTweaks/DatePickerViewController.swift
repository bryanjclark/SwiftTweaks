//
//  DatePickerViewController.swift
//  SwiftTweaks
//
//  Created by Brian Martin on 8/20/19.
//

import Foundation
import UIKit

internal protocol DatePickerViewControllerDelegate {
	func datePickerViewControllerDidPressDismissButton(_ tweakSelectionViewController: DatePickerViewController)
}

/// Allows the user to select an option for a StringListOption value.
internal class DatePickerViewController: UIViewController {
	fileprivate let tweak: Tweak<Date>
	fileprivate let tweakStore: TweakStore
	fileprivate let delegate: DatePickerViewControllerDelegate
	fileprivate let datePicker: UIDatePicker
	fileprivate let dateLabel: UILabel
	fileprivate let dateFormatter = DateFormatter()
	fileprivate let timeFormatter = DateFormatter()
	
	fileprivate var currentOption: Date {
		didSet {
			tweakStore.setValue(
				.date(
					value: currentOption,
					defaultValue: tweak.defaultValue
				),
				forTweak: AnyTweak(tweak: tweak)
			)
		}
	}
	
	fileprivate static let cellIdentifier = "TweakSelectionViewControllerCellIdentifier"
	
    @objc func datePickerChanged(picker: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: datePicker.date) + "\n" + timeFormatter.string(from: datePicker.date)
        currentOption = picker.date
    }

    init(anyTweak: AnyTweak, tweakStore: TweakStore, delegate: DatePickerViewControllerDelegate) {
		assert(anyTweak.tweakViewDataType == .date, "Can only choose a date value in this UI.")
		
		self.tweak = anyTweak.tweak as! Tweak<Date>
		self.tweakStore = tweakStore
		self.delegate = delegate
		self.currentOption = tweakStore.currentValueForTweak(self.tweak)
        self.datePicker = UIDatePicker()
        self.dateLabel = UILabel()

        super.init(nibName: nil, bundle: nil)

        dateFormatter.dateStyle = .long
        timeFormatter.timeStyle = .long
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self,
                             action: #selector(datePickerChanged(picker:)),
                             for: .valueChanged)
        datePicker.date = currentOption
        dateLabel.text = dateFormatter.string(from: datePicker.date) + "\n" + timeFormatter.string(from: datePicker.date)
        dateLabel.numberOfLines = 2
        
		title = tweak.tweakName
		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: TweaksViewController.dismissButtonTitle, style: .done, target: self, action: #selector(self.dismissButtonTapped))
		]
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(DatePickerViewController.restoreDefaultValue))
		self.navigationItem.rightBarButtonItem?.tintColor = AppTheme.Colors.controlDestructive
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        view.addSubview(datePicker)
        view.addSubview(dateLabel)

        view.backgroundColor = .white

        let labelHeight: CGFloat = 60

		datePicker.frame = CGRect(
          origin: view.bounds.origin,
          size: CGSize(
            width: view.bounds.size.width,
            height: view.bounds.size.height-labelHeight/2
          )
        )
		datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        dateLabel.frame = CGRect(
          origin: CGPoint(x: 0, y: view.bounds.size.height-labelHeight-60),
          size: CGSize(width: self.view.frame.width,
                       height: labelHeight)
        )
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.systemFont(ofSize: 24)
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
	// MARK: Events
	
	@objc private func dismissButtonTapped() {
		delegate.datePickerViewControllerDidPressDismissButton(self)
	}
	
	@objc private func restoreDefaultValue() {
		let confirmationAlert = UIAlertController(title: "Reset This Tweak?", message: "Your other tweaks will be left alone. The default value is \(tweak.defaultValue)", preferredStyle: .actionSheet)
		confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		confirmationAlert.addAction(UIAlertAction(title: "Reset Tweak", style: .destructive, handler: { _ in
			                                                                                       self.currentOption = self.tweak.defaultValue
		}))
		present(confirmationAlert, animated: true, completion: nil)
	}
}

