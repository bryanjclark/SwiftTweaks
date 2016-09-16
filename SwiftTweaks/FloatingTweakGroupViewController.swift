//
//  FloatingTweakGroupViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/6/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import UIKit


// MARK: - FloatingTweaksWindowPresenter

internal protocol FloatingTweaksWindowPresenter {
	func presentFloatingTweaksUIForTweakGroup(_ tweakGroup: TweakGroup)
	func dismissFloatingTweaksUI()
}

// MARK: - FloatingTweakGroupViewController

/// A "floating" UI for a particular TweakGroup.
internal final class FloatingTweakGroupViewController: UIViewController {
	var tweakGroup: TweakGroup? {
		didSet {
			titleLabel.text = tweakGroup?.title
			self.tableView.reloadData()
		}
	}

	fileprivate let presenter: FloatingTweaksWindowPresenter
	fileprivate let tweakStore: TweakStore
	fileprivate let fullFrame: CGRect

	internal init(frame: CGRect, tweakStore: TweakStore, presenter: FloatingTweaksWindowPresenter) {
		self.tweakStore = tweakStore
		self.presenter = presenter
		self.fullFrame = frame

		super.init(nibName: nil, bundle: nil)

		view.frame = frame
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	internal var minimizedFrameOriginX: CGFloat {
		return fullFrame.size.width - FloatingTweakGroupViewController.minimizedWidth + FloatingTweakGroupViewController.margins * 2
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		installSubviews()
		layoutSubviews()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		tableView.flashScrollIndicators()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		layoutSubviews()
	}

	// MARK: Subviews

	internal static let height: CGFloat = 168
	internal static let margins: CGFloat = 5
	fileprivate static let minimizedWidth: CGFloat = 30

	fileprivate static let closeButtonSize = CGSize(width: 42, height: 32)
	fileprivate static let navBarHeight: CGFloat = 32
	fileprivate static let windowCornerRadius: CGFloat = 5

	fileprivate let navBar: UIView = {
		let view = UIView()
		view.backgroundColor = AppTheme.Colors.floatingTweakGroupNavBG

		view.layer.shadowColor = AppTheme.Shadows.floatingNavShadowColor
		view.layer.shadowOpacity = AppTheme.Shadows.floatingNavShadowOpacity
		view.layer.shadowOffset = AppTheme.Shadows.floatingNavShadowOffset
		view.layer.shadowRadius = AppTheme.Shadows.floatingNavShadowRadius

		return view
	}()

	fileprivate let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = AppTheme.Colors.sectionHeaderTitleColor
		label.font = AppTheme.Fonts.sectionHeaderTitleFont
		return label
	}()

	fileprivate let closeButton: UIButton = {
		let button = UIButton()
		let buttonImage = UIImage(swiftTweaksImage: .FloatingCloseButton).withRenderingMode(.alwaysTemplate)
		button.setImage(buttonImage.imageTintedWithColor(AppTheme.Colors.controlTinted), for: UIControlState())
		button.setImage(buttonImage.imageTintedWithColor(AppTheme.Colors.controlTintedPressed), for: .highlighted)
		return button
	}()

	fileprivate let tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .clear
		tableView.register(TweakTableCell.self, forCellReuseIdentifier: FloatingTweakGroupViewController.TweakTableViewCellIdentifer)
		tableView.contentInset = UIEdgeInsets(top: FloatingTweakGroupViewController.navBarHeight, left: 0, bottom: 0, right: 0)
		tableView.separatorColor = AppTheme.Colors.tableSeparator
		return tableView
	}()

	fileprivate let restoreButton: UIButton = {
		let button = UIButton()
		let buttonImage = UIImage(swiftTweaksImage: .FloatingMinimizedArrow).withRenderingMode(.alwaysTemplate)
		button.setImage(buttonImage.imageTintedWithColor(AppTheme.Colors.controlSecondary), for: UIControlState())
		button.setImage(buttonImage.imageTintedWithColor(AppTheme.Colors.controlSecondaryPressed), for: .highlighted)
		button.isHidden = true
		return button
	}()

	fileprivate let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

	fileprivate func installSubviews() {
		// Create the rounded corners and shadows
		view.layer.cornerRadius = FloatingTweakGroupViewController.windowCornerRadius
		view.layer.shadowColor = AppTheme.Shadows.floatingShadowColor
		view.layer.shadowOffset = AppTheme.Shadows.floatingShadowOffset
		view.layer.shadowRadius = AppTheme.Shadows.floatingShadowRadius
		view.layer.shadowOpacity = AppTheme.Shadows.floatingShadowOpacity

		// Set up the blurry background
		view.backgroundColor = .clear
		backgroundView.layer.cornerRadius = FloatingTweakGroupViewController.windowCornerRadius
		backgroundView.clipsToBounds = true
		self.view.addSubview(backgroundView)

		// The table view
		tableView.delegate = self
		tableView.dataSource = self
		view.addSubview(tableView)

		// The "fake nav bar"
		closeButton.addTarget(self, action: #selector(self.closeButtonTapped), for: .touchUpInside)
		navBar.addSubview(closeButton)
		navBar.addSubview(titleLabel)
		view.addSubview(navBar)

		// The restore button
		restoreButton.addTarget(self, action: #selector(self.restore), for: .touchUpInside)
		view.addSubview(restoreButton)

		// The pan gesture recognizer
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.moveWindowPanGestureRecognized(_:)))
		panGestureRecognizer.delegate = self
		view.addGestureRecognizer(panGestureRecognizer)
	}

	fileprivate func layoutSubviews() {
		backgroundView.frame = self.view.bounds

		tableView.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: FloatingTweakGroupViewController.height))

		tableView.scrollIndicatorInsets = UIEdgeInsets(
			top: tableView.contentInset.top,
			left: 0,
			bottom: 0,
			right: 0
		)

		navBar.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: FloatingTweakGroupViewController.navBarHeight))

		// Round the top two corners of the nav bar
		navBar.layer.mask = {
			let maskPath = UIBezierPath(
				roundedRect: view.bounds,
				byRoundingCorners: [.topLeft, .topRight],
				cornerRadii: CGSize(
					width: FloatingTweakGroupViewController.windowCornerRadius,
					height: FloatingTweakGroupViewController.windowCornerRadius
				)).cgPath
			let mask = CAShapeLayer()
			mask.path = maskPath
			return mask
			}()

		closeButton.frame = CGRect(origin: .zero, size: FloatingTweakGroupViewController.closeButtonSize)
		titleLabel.frame = CGRect(
			origin: CGPoint(
				x: closeButton.frame.width,
				y: 0
			),
			size: CGSize(
				width: view.bounds.width - closeButton.frame.width,
				height: navBar.bounds.height
			)
		)

		restoreButton.frame = CGRect(
			origin: .zero,
			size: CGSize(
				width: FloatingTweakGroupViewController.minimizedWidth,
				height: view.bounds.height
			)
		)
	}

	// MARK: Actions

	@objc fileprivate func closeButtonTapped() {
		presenter.dismissFloatingTweaksUI()
	}

	fileprivate static let gestureSpeedBreakpoint: CGFloat = 10
	fileprivate static let gesturePositionBreakpoint: CGFloat = 30

	@objc fileprivate func moveWindowPanGestureRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
		switch (gestureRecognizer.state) {
		case .began:
			gestureRecognizer.setTranslation(self.view.frame.origin, in: self.view)
		case .changed:
			view.frame.origin.x = gestureRecognizer.translation(in: self.view).x
		case .possible, .ended, .cancelled, .failed:
			let gestureIsMovingToTheRight = (gestureRecognizer.velocity(in: nil).x > FloatingTweakGroupViewController.gestureSpeedBreakpoint)
			let viewIsKindaNearTheRight = view.frame.origin.x > FloatingTweakGroupViewController.gesturePositionBreakpoint
			if gestureIsMovingToTheRight && viewIsKindaNearTheRight {
				minimize()
			} else {
				restore()
			}
		}
	}

	fileprivate static let minimizeAnimationDuration: Double = 0.3
	fileprivate static let minimizeAnimationDamping: CGFloat = 0.8

	fileprivate func minimize() {
		// TODO map the continuous gesture's velocity into the animation.
		self.restoreButton.alpha = 0
		self.restoreButton.isHidden = false

		UIView.animate(
			withDuration: FloatingTweakGroupViewController.minimizeAnimationDuration,
			delay: 0,
			usingSpringWithDamping: FloatingTweakGroupViewController.minimizeAnimationDamping,
			initialSpringVelocity: 0,
			options: .beginFromCurrentState,
			animations: {
				self.view.frame.origin.x = self.minimizedFrameOriginX
				self.tableView.alpha = 0
				self.navBar.alpha = 0
				self.restoreButton.alpha = 1
			},
			completion: nil
		)
	}

	@objc fileprivate func restore() {
		// TODO map the continuous gesture's velocity into the animation

		UIView.animate(
			withDuration: FloatingTweakGroupViewController.minimizeAnimationDuration,
			delay: 0,
			usingSpringWithDamping: FloatingTweakGroupViewController.minimizeAnimationDamping,
			initialSpringVelocity: 0,
			options: .beginFromCurrentState,
			animations: {
				self.view.frame.origin.x = self.fullFrame.origin.x
				self.tableView.alpha = 1
				self.navBar.alpha = 1
				self.restoreButton.alpha = 0
			},
			completion: { _ in
				self.restoreButton.isHidden = true
			}
		)
	}
}

extension FloatingTweakGroupViewController: UIGestureRecognizerDelegate {
	@objc func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let hitView = gestureRecognizer.view?.hitTest(gestureRecognizer.location(in: gestureRecognizer.view), with: nil) else {
			return true
		}

		// We don't want to move the window if you're trying to drag a slider or a switch!
		// But if you're dragging on the restore button, that's what we do want!
		let gestureIsNotOnAControl = !hitView.isKind(of: UIControl.self)
		let gestureIsOnTheRestoreButton = hitView == restoreButton

		return gestureIsNotOnAControl || gestureIsOnTheRestoreButton
	}
}

// MARK: Table View

extension FloatingTweakGroupViewController: UITableViewDelegate {
	@objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let tweak = tweakAtIndexPath(indexPath) else { return }
		switch tweak.tweakViewDataType {
		case .uiColor:
			let alert = UIAlertController(title: "Can't edit colors here.", message: "Sorry, haven't built out the floating UI for it yet!", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		case .boolean, .integer, .cgFloat, .double:
			break
		}
	}
}

extension FloatingTweakGroupViewController: UITableViewDataSource {
	fileprivate static let TweakTableViewCellIdentifer = "TweakTableViewCellIdentifer"

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweakGroup?.tweaks.count ?? 0
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: FloatingTweakGroupViewController.TweakTableViewCellIdentifer, for: indexPath) as! TweakTableCell

		let tweak = tweakAtIndexPath(indexPath)!

		cell.textLabel?.text = tweak.tweakName
		cell.isInFloatingTweakGroupWindow = true
		cell.viewData = tweakStore.currentViewDataForTweak(tweak)
		cell.delegate = self
		cell.backgroundColor = .clear
		cell.contentView.backgroundColor = .clear

		return cell
	}

	fileprivate func tweakAtIndexPath(_ indexPath: IndexPath) -> AnyTweak? {
		return tweakGroup?.sortedTweaks[(indexPath as NSIndexPath).row]
	}
}

// MARK: TweakTableCellDelegate

extension FloatingTweakGroupViewController: TweakTableCellDelegate {
	func tweakCellDidChangeCurrentValue(_ tweakCell: TweakTableCell) {
		if let
			indexPath = tableView.indexPath(for: tweakCell),
			let viewData = tweakCell.viewData,
			let tweak = tweakAtIndexPath(indexPath)
		{
			tweakStore.setValue(viewData, forTweak: tweak)
		}
	}
}
