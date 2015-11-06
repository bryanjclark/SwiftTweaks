//
//  TweaksViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/5/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

public class TweaksViewController: UIViewController {

	private let store: TweakStore

	public init(store: TweakStore) {
		self.store = store

		super.init(nibName: nil, bundle: nil)
	}

	public required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}