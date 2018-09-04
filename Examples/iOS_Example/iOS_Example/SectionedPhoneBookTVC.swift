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
		self.model.sectionKey = "firstName"
		self.isSectioned = true
        super.viewDidLoad()

	}
	
//	override func addBarButtonAction(_ sender: UIBarButtonItem) {
//
//		let dic = ["id" : 0]
//		var contact = Contact(data: dic)!
//		contact.firstName = "Bob"
//		contact.lastName = "Dilan"
//		contact.phone = "92343423"
//
//		var contact2 = contact
//		contact2.firstName = "Cob"
//		contact2.phone = "93343423"
//
//		var contact3 = contact
//		contact3.firstName = "Cub"
//		contact3.phone = "93443423"
//
//		var contact4 = contact
//		contact4.firstName = "Cuyb"
//		contact4.phone = "94443423"
//
//		var contact5 = contact
//		contact5.firstName = "Duyb"
//		contact5.phone = "95443423"
//
//		self.model.insert([contact, contact2, contact3, contact4, contact5])
//	}


	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.model[section]
		return isSearching ? nil : section.name
	}
}
