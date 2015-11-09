//
//  TweaksViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

public class TweaksViewController: UIViewController {

	private let library: TweakLibraryType

	private let tableView: UITableView

	public init(library: TweakLibraryType) {
		self.library = library

		self.tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)

		super.init(nibName: nil, bundle: nil)

		tableView.bounds = view.bounds
		tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		view.addSubview(tableView)
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}