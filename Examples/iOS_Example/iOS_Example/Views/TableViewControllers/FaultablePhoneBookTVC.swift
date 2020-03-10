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

extension Contact: MAFaultable {
	
	var isFault: Bool {
		
		get {
			return self.image == nil
		}
		
		set(newValue) {
			
		}
	}
	
	mutating func fault() {
		if !self.isFault {
			self.image = nil
		}
	}
	
	mutating func fire() {
		
	}
	
}

class FaultablePhoneBookTVC: BasicTableViewController {
		
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Fault able Phone Book"

	}
	
	override func configureModelAssistant(sectionKey: String?) {
		self.assistant = ModelAssistant(collectionController: self, sectionKey: sectionKey)
	}
	
	override func fetchEntities(completion: (() -> Void)? = nil) {
		self.resourceFileName = "1000_PhoneBook"
		super.fetchEntities()
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print(indexPath.row, separator: "\n")
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		print("Memory Warning")
		if let visibleRows = self.tableView.indexPathsForVisibleRows, !visibleRows.isEmpty {
			let sectionIndex = visibleRows.first!.section
			let firstRow = visibleRows.first!.row
			
			self.assistant.fault(at: sectionIndex, in: 0..<firstRow)
		}
	}
	
}

