//
//  SimplePhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class SimplePhoneBookTVC: UITableViewController, ModelDelegate {

	var model = Model<Contact>()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
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
		var firstNameTextField: UITextField!
		var lastNameTextField: UITextField!
		var phoneTextField: UITextField!

		let alertController = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
		alertController.addTextField { (textField) in
			textField.placeholder = "First Name"
			firstNameTextField = textField
		}
		
		alertController.addTextField { (textField) in
			textField.placeholder = "Last Name"
			lastNameTextField = textField
		}

		alertController.addTextField { (textField) in
			textField.placeholder = "Phone Number"
			phoneTextField = textField
		}

		alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
			
			let dic = ["id" : self.model.uniqueId()]
			var contact = Contact(data: dic)!
			contact.firstName = firstNameTextField.text!
			contact.lastName = lastNameTextField.text!
			contact.phone = phoneTextField.text!
			
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			//...
		}))
		
		self.present(alertController, animated: true, completion: nil)

	}
	
	@objc func sortBarButtonAction(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
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


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.model.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.model.numberOfEntites(at: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
		cell.textLabel?.text = self.model[indexPath].fullName

        return cell
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
			
		default:
			break
		}
	}

}
