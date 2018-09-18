//
//  MutableCoreDataPhoneBookTVCTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class MutableCoreDataPhoneBookTVC: BasicCoreDataTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonAction(_:)))
		
		let saveButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveBarButtonAction(_:)))

		self.navigationItem.rightBarButtonItems = [saveButtonItem, addButtonItem, self.editButtonItem]
		
		let model: Any
		
		model = self.model
		
		if model is CoreDataModel<ContactEntity> {
			let model = model as! CoreDataModel<ContactEntity>
			model.updateMovingEntity = { movingInfo in
				
				let movingEntity = movingInfo.movingEntity
				let oldIndexPath = movingInfo.oldIndexPath
				let newIndexPath = movingInfo.newIndexPath
				
				func orderEntities(forEntities entities: [ContactEntity]) {
						let count = entities.count
						for i in 0..<count {
							let entity = entities[i]
							entity.displayOrder = Int64(i)
						}
					}
				
				var oldSectionEntities = model[oldIndexPath.section]?.objects as! [ContactEntity]
				
				oldSectionEntities.remove(at: oldIndexPath.row)

				var newSectionEntities: [ContactEntity]
				
				if newIndexPath.section != oldIndexPath.section {
					newSectionEntities = model[newIndexPath.section]?.objects as! [ContactEntity]
				}
				else {
					newSectionEntities = oldSectionEntities
				}
				
				newSectionEntities.insert(movingEntity, at: newIndexPath.row)
				
				orderEntities(forEntities: newSectionEntities)
				
			}

		}
		
    }
	
	@objc func addBarButtonAction(_ sender: UIBarButtonItem) {
		self.contactDetailsAlertController(for: nil)
	}
	
	@objc func saveBarButtonAction(_ sender: UIBarButtonItem) {
		
		if ModelAlias<EntityAlias>.self == Model<Contact>.self {
			
			let entities: Any = self.model.getAllEntities(sortedBy: nil)
			let url = JsonService.documentURL.appendingPathComponent(self.resourceFileName + ".json")
			JsonService.saveEntities(entities as! [Contact], toURL: url) {
				
			}

		}
		else {
			try? self.context.save()
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let contact = self.model[indexPath]
		self.contactDetailsAlertController(for: contact)
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		self.model.moveEntity(at: sourceIndexPath, to: destinationIndexPath, isUserDriven: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			self.model.remove(at: indexPath, completion: nil)
		}
	}
	
	
	func contactDetailsAlertController(for contact: EntityAlias?) {
		
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
				}, completion: {
					if let indexPath = self.tableView.indexPathForSelectedRow {
						self.tableView.deselectRow(at: indexPath, animated: true)
					}
				})
			}
			else {
				
				let contact: Any
				
				if EntityAlias.self == Contact.self {
					let dic = ["id" : 0]
					var modelContact = Contact(data: dic)!
					modelContact.firstName = firstNameTextField.text!
					modelContact.lastName = lastNameTextField.text!
					modelContact.phone = phoneTextField.text!
					contact = modelContact
				}
				else {
					let cdContact = ContactEntity(context: self.context)
					cdContact.id = 0
					cdContact.firstName = firstNameTextField.text!
					cdContact.lastName = lastNameTextField.text!
					cdContact.phone = phoneTextField.text!
					contact = cdContact

				}
				
				
				
				self.model.insert([contact as! EntityAlias], completion: nil)
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
