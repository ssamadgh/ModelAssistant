
//
//  UITableViewController+Extension.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

extension UITableViewController: CollectionController {
	
	func insert(at indexPaths: [IndexPath]) {
		self.tableView.insertRows(at: indexPaths, with: .bottom)
	}
	
	func update(at indexPath: IndexPath) {
		if let cell = self.tableView.cellForRow(at: indexPath) {
			self.update(cell, at: indexPath)
			
		}
	}
	
	func delete(at indexPaths: [IndexPath]) {
		self.tableView.deleteRows(at: indexPaths, with: .top)
	}
	
	func move(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		self.tableView.moveRow(at: indexPath, to: newIndexPath)
	}
	
	func insertSection(_ section: Int) {
		self.tableView.insertSections(IndexSet(integer: section), with: .bottom)
	}
	
	func deleteSection(_ section: Int) {
		self.tableView.deleteSections(IndexSet(integer: section), with: .top)
	}
	
	func moveSection(_ section: Int, toSection newSection: Int) {
		self.tableView.moveSection(section, toSection: newSection)
	}
	
	func reloadSection(_ section: Int) {
		self.tableView.reloadSections(IndexSet(integer: section), with: .fade)
	}
	
	func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
		self.tableView.performBatchUpdates(updates, completion: completion)
	}
	
	@objc func update(_ cell: UITableViewCell, at indexPath: IndexPath) {
		
	}
	
}

