//
//  SearchableTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SearchablePhoneBookTVC: SimplePhoneBookTVC {
	
	var searchResults: [Contact] = []
	
	var isSearching: Bool = false
	
	var searchController: UISearchController!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Searchable Phone Book"
		
	}
	
	override func configureModel() {
		self.configureSearchController()
		
		self.model.sectionKey = "firstName"
		self.model.delegate = self
		
		self.model.sortEntities = { $0.firstName < $1.firstName }
		self.model.sortSections = { $0.name < $1.name }
		
		super.configureModel()
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
		return self.isSearching ? 1 : super.numberOfSections(in: tableView)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.isSearching ? self.searchResults.count : super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.model[section]
		return isSearching ? nil : section?.name
	}
	
	override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
		
		let entity = self.isSearching ? self.searchResults[indexPath.row] : self.model[indexPath]
		// Configure the cell...
		cell.textLabel?.text =  entity?.fullName
		
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
	
	// called by our ImageDownloader when an icon is ready to be displayed
	override func imageDidLoad(for entity: CustomEntityProtocol) {
		
		if isSearching {
			if let index = self.searchResults.index(of: entity as! Contact) {
				self.searchResults[index].image = entity.image
				let indexPath = IndexPath(row: index, section: 0)
				if let cell = self.tableView.cellForRow(at: indexPath) {
					self.configure(cell, at: indexPath)
				}
			}
		}
		
		super.imageDidLoad(for: entity)
	}

}

extension SearchablePhoneBookTVC: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {
			if text.isEmpty {
				self.searchResults = self.model.getAllEntities(sortedBy: nil)
			}
			else {
				self.searchResults = self.model.filteredEntities(with: { $0.fullName.contains(text) })
			}
			self.tableView.reloadData()
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.isSearching = false
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.isSearching = true
	}
	
}

