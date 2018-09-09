//
//  PaginationTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/4/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class PaginationPhoneBookTVC: BasicTableViewController {
	
	var insertingNewEntities = false
	
	var manager: ModelDelegateManager!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Pagination Table ViewController"

	}
	
	override func configureModel() {
		self.resourceFileName = "PhoneBook_0"
		self.manager = ModelDelegateManager(controller: self)
		self.model.delegate = self.manager
		self.model.fetchBatchSize = 20
		self.model.sortEntities = { $0.firstName < $1.firstName }
		self.model.sortSections = { $0.name < $1.name }
		self.model.sectionKey = "firstName"
		
		super.configureModel()
	}
	
	
	func insertEntities(from fileName: String) {
		
		guard !insertingNewEntities else {
			return
		}
		
		let tableViewHeight = self.tableView.bounds.height
		let maxOffsetHeight = self.tableView.contentSize.height - tableViewHeight
		let offsetY = self.tableView.contentOffset.y
		
		if offsetY >= maxOffsetHeight {
			
			guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else { return }
			let json = try! Data(contentsOf: url)
			
			let decoder = JSONDecoder()
			let members = try! decoder.decode([Contact].self, from: json)
			self.insertingNewEntities = true
			self.model.insert(members) {
				self.insertingNewEntities = false
			}
		}
	}
	

	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.model[section]?.name
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		self.configure(cell, at: indexPath)
		
		return cell
	}
	
	
	//MARK: - Deferred image loading (UIScrollViewDelegate)

	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
		if !decelerate {
			self.insertEntities(from: "PhoneBook_\(self.model.nextIndex)")
		}
	}
	
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		super.scrollViewDidEndDecelerating(scrollView)
		self.insertEntities(from: "PhoneBook_\(self.model.nextIndex)")
	}

	
}

