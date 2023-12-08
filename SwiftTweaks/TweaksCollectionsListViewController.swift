//
//  TweaksCollectionsListViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweaksCollectionsListViewControllerDelegate: AnyObject {
	func tweaksCollectionsListViewControllerDidTapDismissButton(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController)
	func tweaksCollectionsListViewControllerDidTapShareButton(_ tweaksCollectionsListViewController: TweaksCollectionsListViewController, shareButton: UIBarButtonItem)
	func tweakCollectionListViewController(_ tweakCollectionViewController: TweaksCollectionsListViewController, didTapFloatingTweakGroupButtonForTweakGroup tweakGroup: TweakGroup)
}

/// Displays a list of TweakCollections in a table.
internal final class TweaksCollectionsListViewController: UIViewController {
	private let tableView: UITableView

	private let searchController: UISearchController
	private var searchString: String?
	private var tweaksCollection: [TweakCollection]
	private var filteredTweaksCollection: [TweakCollection]

	fileprivate let tweakStore: TweakStore
	fileprivate unowned var delegate: TweaksCollectionsListViewControllerDelegate

	// MARK: Init

	internal init(tweakStore: TweakStore, delegate: TweaksCollectionsListViewControllerDelegate) {
		self.tweakStore = tweakStore
		self.delegate = delegate

		self.tableView = UITableView(frame: CGRect.zero, style: .plain)
		self.searchController = UISearchController(searchResultsController: nil)
		self.tweaksCollection = tweakStore.sortedTweakCollections
		self.filteredTweaksCollection = tweakStore.sortedTweakCollections
	
		super.init(nibName: nil, bundle: nil)
		self.navigationItem.title = NSLocalizedString("Tweaks", comment: "Navigation title for Tweaks")
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.frame = view.bounds
		tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		tableView.register(TweakCollectionCell.self, forCellReuseIdentifier: TweaksCollectionsListViewController.TweakCollectionCellIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
		view.addSubview(tableView)
	
		if #available(iOS 11.0, *) {
			setupSearchController()
			navigationItem.searchController = searchController
		}
	
		let resetButton = UIBarButtonItem(title: "Reset All", style: .plain, target: self, action: #selector(self.resetStore))
		resetButton.tintColor = AppTheme.Colors.controlDestructive
		navigationItem.rightBarButtonItem = resetButton

		let exportButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(self.actionButtonTapped))
		exportButton.tintColor = AppTheme.Colors.controlTinted
		navigationItem.leftBarButtonItem = exportButton

		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissButtonTapped))
		]
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if let selectedIndexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: selectedIndexPath, animated: true)
		}
	}

	// MARK: SearchController

	private func setupSearchController() {
		searchController.searchResultsUpdater = self
		searchController.searchBar.placeholder = "Search.."
		searchController.searchBar.text = searchString	}

	private func filterAndUpdate() {
		guard let searchString else {
			filteredTweaksCollection = []
			tableView.reloadData()
			return
		}
		filteredTweaksCollection = tweaksCollection.filter { $0.title.localizedCaseInsensitiveContains(searchString) }
		tableView.reloadData()
	}
	
	// MARK: Events

	@objc private func resetStore(_ sender: UIBarButtonItem) {
		let confirmationAlert = UIAlertController(title: nil, message: "Reset all tweaks to their default values?", preferredStyle: .actionSheet)
		confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		confirmationAlert.addAction(UIAlertAction(title: "Reset All Tweaks", style: .destructive, handler: { _ in self.tweakStore.reset() }))
		confirmationAlert.popoverPresentationController?.barButtonItem = sender
		present(confirmationAlert, animated: true, completion: nil)
	}

	@objc private func dismissButtonTapped() {
		delegate.tweaksCollectionsListViewControllerDidTapDismissButton(self)
	}

	@objc private func actionButtonTapped(_ sender: UIBarButtonItem) {
		delegate.tweaksCollectionsListViewControllerDidTapShareButton(self, shareButton: sender)
	}

	fileprivate static let TweakCollectionCellIdentifier = "TweakCollectionCellIdentifier"
	private class TweakCollectionCell: UITableViewCell {
		override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
			super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
			accessoryType = .disclosureIndicator

			let touchHighlightView = UIView()
			touchHighlightView.backgroundColor = AppTheme.Colors.tableCellTouchHighlight
			self.selectedBackgroundView = touchHighlightView
		}

		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
}

// MARK: - UITableViewDataSource
	
extension TweaksCollectionsListViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		numberOfSections
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		numberOfRows
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: TweaksCollectionsListViewController.TweakCollectionCellIdentifier, for: indexPath)
		let tweakCollection = tweak(for: indexPath)
		cell.textLabel!.text = tweakCollection.title
		cell.detailTextLabel!.text = "\(tweakCollection.numberOfTweaks)"
		return cell
	}
}

// MARK: - UITableViewDelegate

extension TweaksCollectionsListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tweakCollection = tweak(for: indexPath)

		let viewController = TweakCollectionViewController(
			tweakCollection: tweakCollection,
			tweakStore: self.tweakStore,
			delegate: self
		)
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}

// MARK: - TweakCollectionViewControllerDelegate

extension TweaksCollectionsListViewController: TweakCollectionViewControllerDelegate {
	func tweakCollectionViewControllerDidPressDismissButton(_ tweakCollectionViewController: TweakCollectionViewController) {
		self.delegate.tweaksCollectionsListViewControllerDidTapDismissButton(self)
	}

	func tweakCollectionViewController(
		_ tweakCollectionViewController: TweakCollectionViewController,
		didTapFloatingTweakGroupButtonForTweakGroup tweakGroup: TweakGroup
	) {
		self.delegate.tweakCollectionListViewController(self, didTapFloatingTweakGroupButtonForTweakGroup: tweakGroup)
	}
}
	
// MARK: - UISearchResultsUpdating
	
extension TweaksCollectionsListViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		searchString = searchController.searchBar.text
		filterAndUpdate()
	}
}
	
// MARK: - Helpers
	
extension TweaksCollectionsListViewController {
	private var isFiltering: Bool {
		guard let searchString else { return false }
		return !searchString.isEmpty
	}
	
	private var numberOfSections: Int { 1 }
	private var numberOfRows: Int { isFiltering ? filteredTweaksCollection.count : tweaksCollection.count }
	private func tweak(for indexPath: IndexPath) -> TweakCollection {
		isFiltering ? filteredTweaksCollection[indexPath.row] : tweaksCollection[indexPath.row]
	}
}
