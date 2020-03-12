//
//  SearchableTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:
	In this file you see, how we use model assistant to implement a search controller.
*/

import UIKit
import ModelAssistant

class SearchablePhoneBookTVC: SimplePhoneBookTVC {
	
	var allEntities: [Contact] = []
	
	var searchAssistant: ModelAssistant<Contact>!
	
	
	var isSearching: Bool = false
	
	var searchController: UISearchController!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Searchable Phone Book"
		
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		self.configureSearchController()
		self.assistant = ModelAssistant<Contact>(collectionController: self, sectionKey: sectionKey)

		self.assistant.sortEntities = { $0.firstName < $1.firstName }
		self.assistant.sortSections = { $0.name < $1.name }
		
	}
	
	override func fetchEntities(completion: (() -> Void)? = nil) {
		super.fetchEntities {
			self.allEntities = self.assistant.getAllEntities(sortedBy: nil)
		}
	}
	
	func configureSearchController() {
		self.searchController = UISearchController(searchResultsController: nil)
		self.searchController.searchResultsUpdater = self
		
		searchController.delegate = self
		searchController.dimsBackgroundDuringPresentation = false // default is YES
		searchController.searchBar.delegate = self    // so we can monitor text changes + others
		
		definesPresentationContext = true
		
		navigationController?.navigationBar.prefersLargeTitles = true
		
		navigationItem.searchController = searchController
		
		// We want the search bar visible all the time.
		navigationItem.hidesSearchBarWhenScrolling = false

	}
	
	
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return self.isSearching ? self.searchAssistant.numberOfSections : super.numberOfSections(in: tableView)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		let numberOfRows = self.assistant.numberOfEntites(at: section)
		return numberOfRows
	}
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = isSearching ? self.searchAssistant[section] : self.assistant[section]
		return section?.name
	}
	
	override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
		
		let entity = self.assistant[indexPath]
		if entity == nil { return }
		
		// Configure the cell...
		cell.textLabel!.text =  entity!.fullName
		
		// Only load cached images; defer new downloads until scrolling ends
		if entity?.image == nil
		{
			if (self.tableView.isDragging == false && self.tableView.isDecelerating == false)
			{
				self.startIconDownload(entity!)
			}
			
			// if a download is deferred or in progress, return a placeholder image
			cell.imageView?.image = UIImage(named: "Placeholder")
		}
		else
		{
			cell.imageView?.image = entity?.image
		}
		cell.imageView?.contentMode = .center
		
	}
	
	override func update(_ cell: UITableViewCell, at indexPath: IndexPath) {
		self.configure(cell, at: indexPath)
	}
	
	// called by our ImageDownloader when an icon is ready to be displayed
	override func downloaded<T>(_ image: UIImage?, forEntity entity: T) {
		
		if isSearching {
			let entity = entity as! Contact
			self.assistant.update(entity, mutate: { (mutateContact) in
				mutateContact.image = image
			}, completion: nil)
			//			if let index = self.searchResults.firstIndex(of: entity as! Contact) {
			//				self.searchResults[index].image = image
			//				let indexPath = IndexPath(row: index, section: 0)
			//				if let cell = self.tableView.cellForRow(at: indexPath) {
			//					self.configure(cell, at: indexPath)
			//				}
			//			}
		}
		
		super.downloaded(image, forEntity: entity)
	}

}

extension SearchablePhoneBookTVC: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {

		if let text = searchController.searchBar.text {
			if text.isEmpty {
//				let allEntities = self.assistant.getAllEntities(sortedBy: nil)

				self.assistant.applyingDifference(from: allEntities, completion: nil)
			}
			else {

				let entities = self.allEntities.filter { $0.fullName.contains(text) }
				self.assistant.applyingDifference(from: entities, completion: nil)

			}
			self.tableView.reloadData()
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//		self.isSearching = false
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//		self.isSearching = true
	}
	
}

