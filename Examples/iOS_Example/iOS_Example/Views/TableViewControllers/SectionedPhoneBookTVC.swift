//
//  SectionedPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/4/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SectionedPhoneBookTVC: SortablePhoneBookTVC {


    override func viewDidLoad() {

		self.model.sectionKey = "firstName"
        super.viewDidLoad()
		self.title = "Sectioned Phone Book"

	}
	
	override func configureModel() {
		self.model.sortSections = { $0.name < $1.name }
		super.configureModel()
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.model[section]
		return section?.name
	}
	
	override func sortBarButtonAction(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
		
		alertController.addAction(UIAlertAction(title: "Section A-Z", style: .default, handler: { (action) in
			self.model.sortSections(with: { $0.name < $1.name }, finished: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "Section Z-A", style: .default, handler: { (action) in
			self.model.sortSections(with: { $0.name > $1.name }, finished: nil)
		}))
		
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
