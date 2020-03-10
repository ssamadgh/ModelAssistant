//
//  MutablePhoneBookCVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import ModelAssistant

class MutablePhoneBookCVC: SimplePhoneBookCVC {

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Mutable Phone Book"
		
		let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonAction(_:)))
		
		let saveButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveBarButtonAction(_:)))
		
		
		self.navigationItem.rightBarButtonItems = [saveButtonItem, addButtonItem, self.editButtonItem]
		
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		self.assistant = ModelAssistant<Contact>(collectionController: self, sectionKey: sectionKey)
	}
	
	override func fetchEntities(completion: (() -> Void)? = nil) {
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
			self.collectionView?.reloadData()
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

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let contact = self.assistant[indexPath]

		if self.isEditing {
			self.deletAlertController(for: contact!)
		}
		else {
			self.contactDetailsAlertController(for: contact)
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		self.assistant.moveEntity(at: sourceIndexPath, to: destinationIndexPath, isUserDriven: true, completion: nil)
	}
	
	func deletAlertController(for contact: Contact) {
		let title = "Are you sure you want to delete “\(contact.fullName)” contact information ?"
		let message = "You can't undo this action."
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
			if let indexPath = self.assistant.indexPath(for: contact) {
				self.assistant.remove(at: indexPath, completion: nil)
			}

		}))
		
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			
			if let indexPath = self.collectionView?.indexPathsForSelectedItems?.first {
				self.collectionView?.deselectItem(at: indexPath, animated: true)
			}
			
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
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

					if let indexPath = self.collectionView?.indexPathsForSelectedItems?.first {
						self.collectionView?.deselectItem(at: indexPath, animated: true)
					}
				})
			}
			else {
				let dic = ["id" : 0]
				var contact = Contact(data: dic)!
				contact.firstName = firstNameTextField.text!
				contact.lastName = lastNameTextField.text!
				contact.phone = phoneTextField.text!
				
				self.assistant.insert([contact], completion: nil)
			}
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			
			if let indexPath = self.collectionView?.indexPathsForSelectedItems?.first {
				self.collectionView?.deselectItem(at: indexPath, animated: true)
			}
			
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}

}
