//
//  SimplePhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/**
Abstract:
In This file SimplePhoneBookTVC implements ModelAssistantDelegate methods with old `beginUpdate()` and `endUpdate` methods
*/

import UIKit
import ModelAssistant

class SimplePhoneBookTVC: BasicTableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Simple Phone Book"
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: sectionKey)
		self.assistant.delegate = self
	}
}


extension SimplePhoneBookTVC: ModelAssistantDelegate {
	
	
	func modelAssistantWillChangeContent() {
		self.tableView.beginUpdates()
	}
	
	func modelAssistantDidChangeContent() {
		self.tableView.endUpdates()
	}
	
	func modelAssistant<Entity>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelAssistantChangeType, newIndexPaths: [IndexPath]?) where Entity : MAEntity, Entity : Hashable {
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
	
	func modelAssistant<Entity>(didChange sectionInfos: [SectionInfo<Entity>], atSectionIndexes sectionIndexes: [Int]?, for type: ModelAssistantChangeType, newSectionIndexes: [Int]?) where Entity : MAEntity, Entity : Hashable {
		
		switch type {
		case .insert:
			self.tableView.insertSections(IndexSet(newSectionIndexes!), with: .bottom)
			
		case .delete:
			self.tableView.deleteSections(IndexSet(newSectionIndexes!), with: .bottom)
			
		case .move:
			for i in sectionIndexes! {
				let oldIndex = sectionIndexes![i]
				let newIndexes = newSectionIndexes![i]
				self.tableView.moveSection(oldIndex, toSection: newIndexes)
			}
			
		case .update:
			break
		}
	}
	
}
