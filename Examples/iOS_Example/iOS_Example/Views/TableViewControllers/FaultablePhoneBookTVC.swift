//
//  ModernPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:

	With model assistant you can call its methods in multiple threads concurrently without worry about race condition or crashing tableView
*/


import UIKit
import ModelAssistant

class FaultablePhoneBookTVC: BasicTableViewController {
	
	var manager: ModelAssistantDelegateManager!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Fault able Phone Book"

	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: sectionKey)
		self.manager = ModelAssistantDelegateManager(controller: self)
		self.assistant.delegate = self.manager
	}
	
	override func fetchEntities() {
		self.resourceFileName = "1000_PhoneBook"
		super.fetchEntities()
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print(indexPath.row, separator: "\n")
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
	
}

