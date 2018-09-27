//
//  MutablePhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class MutablePhoneBookTVC: SimplePhoneBookTVC {

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Mutable Phone Book"

		let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonAction(_:)))
		
		let saveButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveBarButtonAction(_:)))

		
		self.navigationItem.rightBarButtonItems = [saveButtonItem, addButtonItem, self.editButtonItem]
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: sectionKey)
		self.assistant.sortEntities = { $0.firstName < $1.firstName }
		self.assistant.delegate = self
	}
	
	override func fetchEntities() {
		self.resourceFileName = "PhoneBook"

		let documenturl = JsonService.documentURL.appendingPathComponent(self.resourceFileName + ".json")
		
		let url: URL
		if FileManager.default.fileExists(atPath: documenturl.path) {
			url = documenturl
		}
		else {
			let mainUrl = Bundle.main.url(forResource: resourceFileName, withExtension: "json")!
			url = mainUrl
		}
		
		let members: [Contact] = JsonService.getEntities(fromURL: url)
		
		self.assistant.fetch(members) {
			self.tableView.reloadData()
		}
	}

	@objc func addBarButtonAction(_ sender: UIBarButtonItem) {
		self.contactDetailsAlertController(for: nil)
	}
	
	@objc func saveBarButtonAction(_ sender: UIBarButtonItem) {
		let entities = self.assistant.getAllEntities(sortedBy: nil)
		let url = JsonService.documentURL.appendingPathComponent(self.resourceFileName + ".json")
		JsonService.saveEntities(entities, toURL: url) {
			
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contact = self.assistant[indexPath]
		self.contactDetailsAlertController(for: contact)
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

		self.assistant.moveEntity(at: sourceIndexPath, to: destinationIndexPath, isUserDriven: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			self.assistant.remove(at: indexPath, completion: nil)
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
				let indexPath = self.assistant.indexPath(for: contact!)!
				let firstName = firstNameTextField.text!
				let lastName = lastNameTextField.text!
				let phone = phoneTextField.text!
				
				self.assistant.update(at: indexPath, mutate: { (contact) in
					contact.firstName = firstName
					contact.lastName = lastName
					contact.phone = phone
				}, completion: {
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
				
				//				self.assistant.insertAtFirst(contact, applySort: false)
				self.assistant.insert([contact], completion: nil)
			}
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			
			if let indexPath = self.tableView.indexPathForSelectedRow {
				self.tableView.deselectRow(at: indexPath, animated: true)
			}
			
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}

}
