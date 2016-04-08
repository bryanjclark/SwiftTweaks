//
//  TweakBackup.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/20/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import Foundation

/// A "save point" for a given TweakStore. While it's not yet implemented, here's the gist:
/// 1. You should be able to create "backups" of your Tweaks, to encourage experimentation without having to destroy your existing modifications.
/// 2. You should be able to load another person's Backup into your Tweaks - hence the representation as plain text.
/// 3. The backup should be human-readable - preferably it's just the same text that we use when we email somebody.
/// 4. Favor legible backups over having it be "perfect" - the process of parsing a TweakBackup should be forgiving, but if a the parser fails to recognize a Tweak because of a typo or something, that's ¯\_(ツ)_/¯. 
internal struct TweakBackup {
	let text: String

	init(text: String) {
		self.text = text
	}
}