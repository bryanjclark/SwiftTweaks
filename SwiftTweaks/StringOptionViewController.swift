//
//  StringOptionViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 6/22/17.
//  Copyright © 2017 Khan Academy. All rights reserved.
//

import Foundation
import UIKit

internal protocol StringOptionViewControllerDelegate: class {
	func stringOptionViewControllerDidPressDismissButton(_ tweakSelectionViewController: StringOptionViewController)
}

/// Allows the user to select an option for a StringListOption value.
internal class StringOptionViewController: UITableViewController {
	fileprivate let tweak: Tweak<StringOption>
	fileprivate let tweakStore: TweakStore
	fileprivate unowned var delegate: StringOptionViewControllerDelegate
	
	fileprivate var currentOption: String {
		didSet {
			tweakStore.setValue(
				.stringList(
					value: StringOption(value: currentOption),
					defaultValue: tweak.defaultValue,
					options: tweak.options ?? []
				),
				forTweak: AnyTweak(tweak: tweak)
			)
			self.tableView.reloadData()
		}
	}
	
	fileprivate static let cellIdentifier = "TweakSelectionViewControllerCellIdentifier"
	
	init(anyTweak: AnyTweak, tweakStore: TweakStore, delegate: StringOptionViewControllerDelegate) {
		assert(anyTweak.tweakViewDataType == .stringList, "Can only choose a string list value in this UI.")
		
		self.tweak = anyTweak.tweak as! Tweak<StringOption>
		self.tweakStore = tweakStore
		self.delegate = delegate
		self.currentOption = tweakStore.currentValueForTweak(self.tweak).value
		
		super.init(style: UITableView.Style.plain)
		
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: StringOptionViewController.cellIdentifier)
		self.tableView.reloadData()
		
		title = tweak.tweakName
		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: TweaksViewController.dismissButtonTitle, style: .done, target: self, action: #selector(self.dismissButtonTapped))
		]
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(StringOptionViewController.restoreDefaultValue))
		self.navigationItem.rightBarButtonItem?.tintColor = AppTheme.Colors.controlDestructive
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweak.options?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCell(withIdentifier: StringOptionViewController.cellIdentifier)!
		let option = tweak.options![indexPath.row].value
	
		cell.textLabel?.text = option
		cell.accessoryType = (option == self.currentOption) ? .checkmark : .none
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.currentOption = tweak.options![indexPath.row].value
		self.navigationController?.popViewController(animated: true)
	}
	
	
	// MARK: Events
	
	@objc private func dismissButtonTapped() {
		delegate.stringOptionViewControllerDidPressDismissButton(self)
	}
	
	@objc private func restoreDefaultValue() {
		let confirmationAlert = UIAlertController(title: "Reset This Tweak?", message: "Your other tweaks will be left alone. The default value is \(tweak.defaultValue.value)", preferredStyle: .actionSheet)
		confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		confirmationAlert.addAction(UIAlertAction(title: "Reset Tweak", style: .destructive, handler: { _ in
			self.currentOption = self.tweak.defaultValue.value
		}))
		present(confirmationAlert, animated: true, completion: nil)
	}
}

