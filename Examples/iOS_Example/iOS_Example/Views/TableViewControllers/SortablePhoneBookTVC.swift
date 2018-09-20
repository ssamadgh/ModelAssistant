//
//  SortablePhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SortablePhoneBookTVC: SimplePhoneBookTVC {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Sortable Phone Book"
		
		let sortButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortBarButtonAction(_:)))
		
		self.navigationItem.rightBarButtonItem = sortButtonItem

	}
	
	override func configureModel(sectionKey: String?) {
		super.configureModel(sectionKey: sectionKey)
		self.model.sortEntities = { $0.firstName < $1.firstName }
	}
	
	@objc func sortBarButtonAction(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
				
		alertController.addAction(UIAlertAction(title: "First Name A-Z", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.firstName < $1.firstName }
			self.model.reorder(completion: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name Z-A", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.firstName > $1.firstName }
			self.model.reorder(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name A-Z", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.lastName < $1.lastName }
			self.model.reorder(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name Z-A", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.lastName > $1.lastName }
			self.model.reorder(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			//...
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
}
