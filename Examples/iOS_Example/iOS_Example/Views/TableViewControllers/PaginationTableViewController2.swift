//
//  PaginationTableViewController2.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class PaginationTableViewController2: UITableViewController, ImageDownloaderDelegate {
	
	var imageDownloadsInProgress: [Int : ImageDownloader]!  // the set of IconDownloader objects for each app
	
	var insertingNewEntities = false
	
	var model = Model<Contact>()
	
	var manager: ModelDelegateManager!
	
	var searchResults: [Contact] = []
	
	var isSearching: Bool = false
	
	var searchController: UISearchController!
	
	var isSectioned: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.imageDownloadsInProgress = [:]
		
		self.title = "Pagination Table ViewController"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		
		let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonAction(_:)))
		
		let sortButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortBarButtonAction(_:)))
		
		self.navigationItem.rightBarButtonItems = [addButtonItem, self.editButtonItem, sortButtonItem]
		
		self.configureSearchController()
		
		self.configureModel()
		
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
	
	func configureModel() {
		let url = Bundle.main.url(forResource: "PhoneBook_0", withExtension: "json")!
		let json = try! Data(contentsOf: url)
		
		let decoder = JSONDecoder()
		let members = try! decoder.decode([Contact].self, from: json)
		self.manager = ModelDelegateManager(controller: self)
		self.model.delegate = self
		self.model.fetchBatchSize = 20
		self.model.sortEntities = { $0.firstName < $1.firstName }
		self.model.sortSections = { $0.name < $1.name }
		
		self.model.sectionKey = "firstName"
		
		self.model.fetch(members) {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
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
	
	@objc func addBarButtonAction(_ sender: UIBarButtonItem) {
		self.contactDetailsAlertController(for: nil)
	}
	
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.model[section]?.name
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return self.isSearching ? 1 : self.model.numberOfSections
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.isSearching ? self.searchResults.count : self.model.numberOfEntites(at: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		self.configure(cell, at: indexPath)
		
		return cell
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
				self.startIconDownload(entity!, for: indexPath)
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contact = self.model[indexPath]
		self.contactDetailsAlertController(for: contact)
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		print("moved")
		self.model.moveEntity(at: sourceIndexPath, to: destinationIndexPath, isUserDriven: true)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			self.model.remove(at: indexPath, removeEmptySection: true)
		}
	}
	
	//MARK: - Table cell image support
	func startIconDownload(_ entity: Contact, for indexPath: IndexPath) {
		let uniqueValue = entity.uniqueValue
		var imageDownloader: ImageDownloader! = imageDownloadsInProgress[uniqueValue]
		if imageDownloader == nil {
			imageDownloader = ImageDownloader()
			imageDownloader.entity = entity
			imageDownloader.delegate = self
			imageDownloadsInProgress[uniqueValue] = imageDownloader
			imageDownloader.startDownload()
		}
	}
	
	// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
	func loadImagesForOnscreenRows() {
		if self.model.numberOfFetchedEntities > 0 {
			let visiblePaths = self.tableView.indexPathsForVisibleRows ?? []
			for indexPath in visiblePaths {
				let entity = self.model[indexPath]
				if entity?.image == nil // avoid the app icon download if the app already has an icon
				{
					self.startIconDownload(entity!, for: indexPath)
				}
			}
		}
	}
	
	// called by our ImageDownloader when an icon is ready to be displayed
	func imageDidLoad(for entity: CustomEntityProtocol) {
		
		self.model.update(at: self.model.indexPath(of: entity as! Contact)!, mutate: { (contact) in
			contact.image = entity.image
		})
		
		// Remove the IconDownloader from the in progress list.
		// This will result in it being deallocated.
		self.imageDownloadsInProgress.removeValue(forKey: entity.uniqueValue)
	}
	
	//MARK: - Deferred image loading (UIScrollViewDelegate)
	
	
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			self.loadImagesForOnscreenRows()
			
			self.insertEntities(from: "PhoneBook_\(self.model.nextIndex)")
			
		}
	}
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.loadImagesForOnscreenRows()
		self.insertEntities(from: "PhoneBook_\(self.model.nextIndex)")
		
	}
	
	func contactDetailsAlertController(for contact: Contact?) {
		
		var firstNameTextField: UITextField!
		var lastNameTextField: UITextField!
		var phoneTextField: UITextField!
		
		let alertController = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
		alertController.addTextField { (textField) in
			firstNameTextField = textField
			firstNameTextField.placeholder = "First Name"
			firstNameTextField.text = contact?.firstName
			
		}
		
		alertController.addTextField { (textField) in
			lastNameTextField = textField
			lastNameTextField.placeholder = "Last Name"
			lastNameTextField.text = contact?.lastName
		}
		
		alertController.addTextField { (textField) in
			phoneTextField = textField
			phoneTextField.placeholder = "Phone Number"
			phoneTextField.text = contact?.phone
			phoneTextField.keyboardType = .phonePad
		}
		
		let doneButtonTitle = contact == nil ? "Add" : "Update"
		alertController.addAction(UIAlertAction(title: doneButtonTitle, style: .default, handler: { (action) in
			if contact != nil {
				let indexPath = self.model.indexPath(of: contact!)!
				let firstName = firstNameTextField.text!
				let lastName = lastNameTextField.text!
				let phone = phoneTextField.text!
				
				self.model.update(at: indexPath, mutate: { (contact) in
					contact.firstName = firstName
					contact.lastName = lastName
					contact.phone = phone
				}, finished: {
					if let indexPath = self.tableView.indexPathForSelectedRow {
						self.tableView.deselectRow(at: indexPath, animated: true)
					}
				})
			}
			else {
				let dic = ["id" : 0]
				var contact = Contact(data: dic)!
				contact.firstName = firstNameTextField.text!
				contact.lastName = lastNameTextField.text!
				contact.phone = phoneTextField.text!
				
				//				self.model.insertAtFirst(contact, applySort: false)
				self.model.insert([contact])
			}
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			
			if let indexPath = self.tableView.indexPathForSelectedRow {
				self.tableView.deselectRow(at: indexPath, animated: true)
			}
			
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
	@objc func sortBarButtonAction(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
		
		if isSectioned {
			alertController.addAction(UIAlertAction(title: "Section A-Z", style: .default, handler: { (action) in
				self.model.sortSections(by: { $0.name < $1.name }, finished: nil)
			}))
			
			alertController.addAction(UIAlertAction(title: "Section Z-A", style: .default, handler: { (action) in
				self.model.sortSections(by: { $0.name < $1.name }, finished: nil)
			}))
		}
		
		alertController.addAction(UIAlertAction(title: "First Name A-Z", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.firstName < $1.firstName }
			self.model.reorder(finished: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name Z-A", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.firstName > $1.firstName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name A-Z", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.lastName < $1.lastName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name Z-A", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.lastName > $1.lastName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			//...
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
}

extension PaginationTableViewController2: ModelDelegate {
	
	func modelWillChangeContent(for type: ModelChangeType) {
		print("Will Change with type: \(type)")
		self.tableView.beginUpdates()
	}
	
	func modelDidChangeContent(for type: ModelChangeType) {
		print("Did Change with type: \(type)")

		self.tableView.endUpdates()
	}
	
	func model(didChange entities: [EntityProtocol], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
		switch type {
		case .insert:
			self.tableView.insertRows(at: newIndexPaths!, with: .bottom)
			
		case .delete:
			self.tableView.deleteRows(at: indexPaths!, with: .top)
			
		case .move:
			for i in 0..<indexPaths!.count {
				self.tableView.moveRow(at: indexPaths![i], to: newIndexPaths![i])
			}
		case .update:
			let indexPath = indexPaths!.first!
			if let cell = self.tableView.cellForRow(at: indexPath) {
				self.configure(cell, at: indexPath)
			}
			
		}
	}
	
	func model(didChange sectionInfo: ModelSectionInfo, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) {
		switch type {
		case .insert:
			self.tableView.insertSections(IndexSet(integer: newSectionIndex!), with: .bottom)
			
		case .delete:
			self.tableView.deleteSections(IndexSet(integer: newSectionIndex!), with: .bottom)
			
		case .move:
			self.tableView.moveSection(sectionIndex!, toSection: newSectionIndex!)
			
		case .update:
			break
		}
	}
	
}

extension PaginationTableViewController2: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
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
