//
//  PaginationTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/4/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

/*
Abstract:
	With model assistant you can fetch entities in form of lazy loading.
*/


import UIKit
import ModelAssistant

class PaginationPhoneBookTVC: BasicTableViewController {
	
	var insertingNewEntities = false
	
	var manager: ModelAssistantDelegateManager!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Pagination Phone Book"
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: "firstName")
		self.manager = ModelAssistantDelegateManager(controller: self)
		self.assistant.delegate = self.manager
		self.assistant.fetchBatchSize = 20
		self.assistant.sortEntities = { $0.firstName < $1.firstName }
		self.assistant.sortSections = { $0.name < $1.name }
	}
	
	override func fetchEntities() {
		self.resourceFileName = "PhoneBook_0"
		super.fetchEntities()
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
			self.assistant.insert(members) {
				self.insertingNewEntities = false
			}
		}
	}
	

	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.assistant[section]?.name
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
			self.insertEntities(from: "PhoneBook_\(self.assistant.nextFetchIndex)")
		}
	}
	
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		super.scrollViewDidEndDecelerating(scrollView)
		self.insertEntities(from: "PhoneBook_\(self.assistant.nextFetchIndex)")
	}
	
}

