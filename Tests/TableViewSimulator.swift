//
//  TableViewControllerSimulator.swift
//  Model
//
//  Created by Seyed Samad Gholamzadeh on 9/21/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewSimulator {
	
	func beginUpdates()
	
	func endUpdates()
	
	func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
	
	func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
	
	func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
	
	func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
	
	func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
	
	func moveSection(_ section: Int, toSection newSection: Int)
	
	func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?)

}

//class SSS: NSObject, UITableViewDataSource {
//
//	func numberOfSections(in tableView: UITableView) -> Int {
//
//	}
//
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//	}
//
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//	}
//	
//	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//		
//	}
//
//}

class SSS2: NSObject, UITableViewDelegate {
	
	
}

protocol TableViewSimulatorDataSource {
	
	func numberOfSections(in tableView: TableViewSimulator) -> Int
	
	func tableView(_ tableView: TableViewSimulator, numberOfRowsInSection section: Int) -> Int
	
	func tableView(_ tableView: TableViewSimulator, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
	
}



extension UITableView: TableViewSimulator {
	
	
}

class TableView: UITableView {
	
	var numberOfSectionsBeforeUpdates: Int!
	var numberOfRowsBeforeUpdates: [Int]!

	var numberOfSectionsAfterUpdates: Int!
	var numberOfRowsAfterUpdates: [Int]!

	override func beginUpdates() {
		let numberOfSections = self.dataSource?.numberOfSections?(in: self) ?? 0
		let numberOfRows = (0..<numberOfSections).map { self.dataSource?.tableView(self, numberOfRowsInSection: $0) ?? 0 }
		
		self.numberOfSectionsBeforeUpdates = numberOfSections
		self.numberOfRowsBeforeUpdates = numberOfRows
	}

	override func endUpdates() {
		let numberOfSections = self.dataSource?.numberOfSections?(in: self) ?? 0
		let numberOfRows = (0..<numberOfSections).map { self.dataSource?.tableView(self, numberOfRowsInSection: $0) ?? 0 }
		
		self.numberOfSectionsAfterUpdates = numberOfSections
		self.numberOfRowsAfterUpdates = numberOfRows
	}
	
	override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		
	}
	
	override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		
	}
	
	override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		
	}
	
	override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		
	}
	
	override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		
	}
	
	override func moveSection(_ section: Int, toSection newSection: Int) {
		
	}
	
	override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
		
	}
	
	
	
}
