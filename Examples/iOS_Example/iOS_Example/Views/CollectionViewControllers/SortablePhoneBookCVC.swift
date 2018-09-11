//
//  SortablePhoneBookCVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SortablePhoneBookCVC: SimplePhoneBookCVC {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Sortable Phone Book"
		
		let sortButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortBarButtonAction(_:)))
		
		self.navigationItem.rightBarButtonItem = sortButtonItem
		
	}
	
	override func configureModel() {
		self.model.sortEntities = { $0.firstName < $1.firstName }
		super.configureModel()
	}
	
	@objc func sortBarButtonAction(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
		
		alertController.addAction(UIAlertAction(title: "First Name A-Z", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.firstName < $1.firstName }
<<<<<<< HEAD
			self.model.reorder(completion: nil)
=======
			self.model.reorder(finished: nil)
>>>>>>> 30617f2d6fef745b44c857447ace41e0c7a9c199
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name Z-A", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.firstName > $1.firstName }
<<<<<<< HEAD
			self.model.reorder(completion: nil)
=======
			self.model.reorder(finished: nil)
>>>>>>> 30617f2d6fef745b44c857447ace41e0c7a9c199
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name A-Z", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.lastName < $1.lastName }
<<<<<<< HEAD
			self.model.reorder(completion: nil)
=======
			self.model.reorder(finished: nil)
>>>>>>> 30617f2d6fef745b44c857447ace41e0c7a9c199
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name Z-A", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.lastName > $1.lastName }
<<<<<<< HEAD
			self.model.reorder(completion: nil)
=======
			self.model.reorder(finished: nil)
>>>>>>> 30617f2d6fef745b44c857447ace41e0c7a9c199
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			//...
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
}
