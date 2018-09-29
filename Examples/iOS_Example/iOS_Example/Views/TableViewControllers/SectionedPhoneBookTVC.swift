//
//  SectionedPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/4/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:
	This file configures model assistant to devide entities into multiple sections.
	In addition, it confiures model assistant to shows sections sorted.
*/


import UIKit
import ModelAssistant

class SectionedPhoneBookTVC: SortablePhoneBookTVC {


    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Sectioned Phone Book"
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		//Configuring model assistant to devide entities into multiple sections
		super.configureModelAssistant(sectionKey: "firstName")
		
		// Configuring model assistant to shows sections sorted
		self.assistant.sortSections = { $0.name < $1.name }
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.assistant[section]
		return section?.name
	}
	
	override func sortBarButtonAction(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
		
		alertController.addAction(UIAlertAction(title: "Section A-Z", style: .default, handler: { (action) in
			self.assistant.sortSections(by: { $0.name < $1.name }, completion: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "Section Z-A", style: .default, handler: { (action) in
			self.assistant.sortSections(by: { $0.name > $1.name }, completion: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name A-Z", style: .default, handler: { (action) in
			self.assistant.sortEntities = { $0.firstName < $1.firstName }
			self.assistant.reorderEntities(completion: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name Z-A", style: .default, handler: { (action) in
			self.assistant.sortEntities = { $0.firstName > $1.firstName }
			self.assistant.reorderEntities(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name A-Z", style: .default, handler: { (action) in
			self.assistant.sortEntities = { $0.lastName < $1.lastName }
			self.assistant.reorderEntities(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name Z-A", style: .default, handler: { (action) in
			self.assistant.sortEntities = { $0.lastName > $1.lastName }
			self.assistant.reorderEntities(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			//...
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}

}
