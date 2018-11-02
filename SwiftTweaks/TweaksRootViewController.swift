
//
//  TweaksRootViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/10/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweaksRootViewControllerDelegate {
	func tweaksRootViewControllerDidPressDismissButton(_ tweaksRootViewController: TweaksRootViewController)
	func tweaksRootViewController(_ tweaksRootViewController: TweaksRootViewController, requestsFloatingUIForTweakGroup tweakGroup: TweakGroup)
}

/// A "container" view controller with two states: listing out the TweakCollections, or displaying the TweakBackups
internal final class TweaksRootViewController: UIViewController {

	private let segmentedControl: UISegmentedControl
	fileprivate let tweakStore: TweakStore
	fileprivate let delegate: TweaksRootViewControllerDelegate

	private var content: Content? {
		didSet {
			if let newContent = content {
				let newContentViewController = newContent.viewController
				let newContentView = newContentViewController.view

				newContentView?.frame = view.bounds
				newContentView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

				view.addSubview(newContentView!)
				addChild(newContentViewController)
				newContentViewController.didMove(toParent: self)

				toolbarItems = newContentViewController.toolbarItems
				navigationItem.leftBarButtonItem = newContentViewController.navigationItem.leftBarButtonItem
				navigationItem.rightBarButtonItem = newContentViewController.navigationItem.rightBarButtonItem
			}

			if let oldContent = oldValue {
				oldContent.viewController.view.removeFromSuperview()
				oldContent.viewController.removeFromParent()
			}
		}
	}

	init(tweakStore: TweakStore, delegate: TweaksRootViewControllerDelegate) {
		self.tweakStore = tweakStore
		self.delegate = delegate

		self.segmentedControl = UISegmentedControl(
			items: [
				NSLocalizedString("Tweaks", comment: "Segmented Control title for tweaks."),
				NSLocalizedString("Backups", comment: "Segmented Control title for backups.")
			]
		)

		super.init(nibName: nil, bundle: nil)

		self.navigationItem.title = "Tweaks"
//		self.navigationItem.titleView = segmentedControl

		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.content = Content.collectionsListWithTweakStore(tweakStore, delegate: self)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	@objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
		assert(sender == segmentedControl)
		switch sender.selectedSegmentIndex {
		case 0:
			content = Content.collectionsListWithTweakStore(tweakStore, delegate: self)
		case 1:
			content = Content.backupsListWithTweaksStore(tweakStore, delegate: self)
		default:
			assertionFailure("Unexpected number of indeces in segmentedControl")
		}
	}


	// MARK: Content

	private enum Content {
		case collectionsList(UIViewController)
		case backupsList(UIViewController)

		var viewController: UIViewController {
			switch self {
			case .collectionsList(let viewController):
				return viewController
			case .backupsList(let viewController):
				return viewController
			}
		}

		fileprivate static func collectionsListWithTweakStore(_ tweakStore: TweakStore, delegate: TweaksCollectionsListViewControllerDelegate) -> Content {
			return .collectionsList(TweaksCollectionsListViewController(tweakStore: tweakStore, delegate: delegate))
		}

		fileprivate static func backupsListWithTweaksStore(_ tweakStore: TweakStore, delegate: TweaksBackupsListViewControllerDelegate) -> Content {
			return .backupsList(TweaksBackupsListViewController(tweakStore: tweakStore, delegate: delegate))
		}
	}
}

extension TweaksRootViewController: TweaksCollectionsListViewControllerDelegate {
	func tweaksCollectionsListViewControllerDidTapDismissButton(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController) {
		delegate.tweaksRootViewControllerDidPressDismissButton(self)
	}

	func tweaksCollectionsListViewController(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController, didSelectTweakCollection tweakCollection: TweakCollection) {
		let tweakCollectionViewController = TweakCollectionViewController(tweakCollection: tweakCollection, tweakStore: tweakStore, delegate: self)
		self.navigationController?.pushViewController(tweakCollectionViewController, animated: true)
	}

	func tweaksCollectionsListViewControllerDidTapShareButton(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController, shareButton: UIBarButtonItem) {
		let activityVC = UIActivityViewController(activityItems: [TweakStoreActivityItemSource(text: tweakStore.textRepresentation)], applicationActivities: nil)
		activityVC.popoverPresentationController?.barButtonItem = shareButton
		present(activityVC, animated: true, completion: nil)
	}
}

extension TweaksRootViewController: TweaksBackupsListViewControllerDelegate {
	func tweaksBackupsListDidPressDismiss(_ tweaksBackupsListViewController: TweaksBackupsListViewController) {
		delegate.tweaksRootViewControllerDidPressDismissButton(self)
	}
}

extension TweaksRootViewController: TweakCollectionViewControllerDelegate {
	func tweakCollectionViewControllerDidPressDismissButton(_ tweakCollectionViewController: TweakCollectionViewController) {
		delegate.tweaksRootViewControllerDidPressDismissButton(self)
	}

	func tweakCollectionViewController(_ tweakCollectionViewController: TweakCollectionViewController, didTapFloatingTweakGroupButtonForTweakGroup tweakGroup: TweakGroup) {
		delegate.tweaksRootViewController(self, requestsFloatingUIForTweakGroup: tweakGroup)
	}
}
