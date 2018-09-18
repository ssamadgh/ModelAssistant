//
//  ModernPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class ThreadSafePhoneBookTVC: BasicTableViewController {
	
	private let dispatchQueue = DispatchQueue(label: "com.ThreadSafePhoneBookTVC.ConcirrentGCD.DispatchQueue", attributes: DispatchQueue.Attributes.concurrent)
	
	var manager: ModelDelegateManager!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Thread Safe Phone Book"
		
		let doMagicButtonItem = UIBarButtonItem(title: "Do Magic!", style: .plain, target: self, action: #selector(doMagicBarButtonAction(_:)))
		
		self.navigationItem.rightBarButtonItems = [doMagicButtonItem]
		
	}
	
	override func configureModel() {
		self.manager = ModelDelegateManager(controller: self)
		//		self.model.delegate = self.manager
		self.model.delegate = self
		super.configureModel()
	}
	
	@objc func doMagicBarButtonAction(_ sender: UIBarButtonItem) {
		
		let firstIndexPath = IndexPath(row: 0, section: 0)
		
		let dic = ["id" : 0]
		var contact = Contact(data: dic)!
		contact.firstName = "Samad"
		contact.lastName = "Khatar"
		contact.phone = "9934243243"
		
		self.dispatchQueue.async {
			
			self.model.insert(contact, at: firstIndexPath)
		}
		
		self.dispatchQueue.async {
			contact.firstName = "Abbas"
			contact.phone = "9342432432"
			self.model.insert(contact, at: firstIndexPath)
		}
		
		self.dispatchQueue.async {
			self.model.remove(at: IndexPath(row: 2, section: 0))
		}
		
		self.dispatchQueue.async {
			self.model.update(at: IndexPath(row: 3, section: 0), mutate:  { (contact) in
				contact.firstName = "Joooooojoooo"
				contact.lastName = "Talaaaaaaaieeeee"
			}, completion: nil)
		}
		
	}
	
}

extension ThreadSafePhoneBookTVC: ModelDelegate {
	func modelWillChangeContent() {
		self.tableView.beginUpdates()
	}
	
	func modelDidChangeContent() {
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
