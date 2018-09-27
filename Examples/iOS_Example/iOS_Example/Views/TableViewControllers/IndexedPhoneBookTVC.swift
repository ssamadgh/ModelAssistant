//
//  IndexedPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class IndexedPhoneBookTVC: SectionedPhoneBookTVC {

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Indexed Phone Book"
		self.navigationItem.rightBarButtonItem = nil

	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return self.assistant.sectionIndexTitles
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return self.assistant.section(forSectionIndexTitle: title, at: index)
	}

}
