
//
//  UITableViewController+Extension.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

public protocol MATableViewContainer: MACollectionController {

	var tableView: UITableView! { get set }

	func update(_ cell: UITableViewCell, at indexPath: IndexPath)

}

extension MATableViewContainer {

	public func maInsert(at indexPaths: [IndexPath]) {
		self.tableView.insertRows(at: indexPaths, with: .bottom)
	}

	public func maUpdate(at indexPath: IndexPath) {
		if let cell = self.tableView.cellForRow(at: indexPath) {
			self.update(cell, at: indexPath)

		}
	}

	public func maDelete(at indexPaths: [IndexPath]) {
		self.tableView.deleteRows(at: indexPaths, with: .top)
	}

	public func maMove(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		self.tableView.moveRow(at: indexPath, to: newIndexPath)
	}

	public func maInsertSections(_ sections: IndexSet) {
		self.tableView.insertSections(sections, with: .bottom)
	}

	public func maDeleteSections(_ sections: IndexSet) {
		self.tableView.deleteSections(sections, with: .top)
	}

	public func maMoveSection(_ section: Int, toSection newSection: Int) {
		self.tableView.moveSection(section, toSection: newSection)
	}

	public func maReloadSections(_ sections: IndexSet) {
		self.tableView.reloadSections(sections, with: .fade)
	}

	public func maPerformBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
		if #available(iOS 11.0, *) {
			self.tableView.performBatchUpdates(updates, completion: completion)
		} else {
			// Fallback on earlier versions
			self.tableView.beginUpdates()
			updates?()
			self.tableView.endUpdates()
			completion?(true)
		}
	}


}

extension UITableViewController: MATableViewContainer {

	@objc open func update(_ cell: UITableViewCell, at indexPath: IndexPath) {

	}

}

