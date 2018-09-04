//
//  SimplePhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class SimplePhoneBookTVC: UITableViewController, ModelDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

	var model = Model<Contact>()
	
	var searchResults: [Contact] = []
	
	var isSearching: Bool = false
	
	var searchController: UISearchController!
	
	var isSectioned: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
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

		
		self.title = "Simple Phone Book"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

		let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonAction(_:)))
		
		let sortButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortBarButtonAction(_:)))
		
		self.navigationItem.rightBarButtonItems = [addButtonItem, self.editButtonItem, sortButtonItem]
		let url = Bundle.main.url(forResource: "PhoneBook", withExtension: "json")!
		let json = try! Data(contentsOf: url)
		
		let decoder = JSONDecoder()
		let members = try! decoder.decode([Contact].self, from: json)
		
		self.model.delegate = self
		self.model.fetch(members) {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}

	}

	@objc func addBarButtonAction(_ sender: UIBarButtonItem) {
		self.contactDetailsAlertController(for: nil)
	}
	

    // MARK: - Table view data source

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

        // Configure the cell...
		cell.textLabel?.text =  self.isSearching ? self.searchResults[indexPath.row].fullName : self.model[indexPath].fullName

        return cell
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
	
	func modelWillChangeContent(for type: ModelChangeType) {
		self.tableView.beginUpdates()
	}
	
	func modelDidChangeContent(for type: ModelChangeType) {
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
				cell.textLabel?.text = self.model[indexPath].fullName
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
				self.model.sortSections(with: { $0.name < $1.name }, finished: nil)
			}))
			
			alertController.addAction(UIAlertAction(title: "Section Z-A", style: .default, handler: { (action) in
				self.model.sortSections(with: { $0.name < $1.name }, finished: nil)
			}))
		}
		
		alertController.addAction(UIAlertAction(title: "First Name A-Z", style: .default, handler: { (action) in
			self.model.sort = { $0.firstName < $1.firstName }
			self.model.reorder(finished: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name Z-A", style: .default, handler: { (action) in
			self.model.sort = { $0.firstName > $1.firstName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name A-Z", style: .default, handler: { (action) in
			self.model.sort = { $0.lastName < $1.lastName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name Z-A", style: .default, handler: { (action) in
			self.model.sort = { $0.lastName > $1.lastName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			//...
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
}

extension SimplePhoneBookTVC {
	
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {
			if text.isEmpty {
				self.searchResults = self.model.allEntitiesForExport(sortedBy: nil)
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
