//
//  SimplePhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class SimplePhoneBookTVC: BasicTableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Simple Phone Book"
	}
	
	override func configureModel(sectionKey: String?) {
		super.configureModel(sectionKey: sectionKey)
		self.model.delegate = self
	}
}


extension SimplePhoneBookTVC: ModelDelegate {
	
	
	func modelWillChangeContent() {
		self.tableView.beginUpdates()
	}
	
	func modelDidChangeContent() {
		self.tableView.endUpdates()
	}
	
	func model<Entity>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) where Entity : EntityProtocol, Entity : Hashable {
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
	
	func model<Entity>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) where Entity : EntityProtocol, Entity : Hashable {
		
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
