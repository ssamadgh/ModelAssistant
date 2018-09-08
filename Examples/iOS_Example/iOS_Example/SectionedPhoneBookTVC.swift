//
//  SectionedPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/4/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SectionedPhoneBookTVC: SimplePhoneBookTVC {

    override func viewDidLoad() {
		self.title = "Sectioned Phone Book"

		self.model.sectionKey = "firstName"
		self.isSectioned = true
        super.viewDidLoad()

	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.model[section]
		return isSearching ? nil : section.name
	}
}
