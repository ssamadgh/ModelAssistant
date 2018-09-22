//
//  TableViewTest.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 9/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//


import XCTest
import Foundation
import UIKit

protocol TableViewTestProtocol {
	
	func beginUpdates()
	
//	func endUpdates()
	
	func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
	
	func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
	
	func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
	
	func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
	
	func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
	
//	func moveSection(_ section: Int, toSection newSection: Int)
	
	func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?)
	
}



protocol TableViewTestDataSource {
	
	func numberOfSections(in tableView: TableViewTestProtocol) -> Int
	
	func tableView(_ tableView: TableViewTestProtocol, numberOfRowsInSection section: Int) -> Int
	
	func tableView(_ tableView: TableViewTestProtocol, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
	
}

extension TableViewTestDataSource {
	
	func tableView(_ tableView: TableViewTestProtocol, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
	}

}



extension UITableView: TableViewTestProtocol {
	
	
}

class TableViewTest: XCTestCase, TableViewTestProtocol {
	
	var expectation: XCTestExpectation!
	var dataSource: TableViewTestDataSource?
	
	var numberOfSectionsBeforeUpdates: Int!
	var numberOfRowsBeforeUpdates: [Int]!
	
	var numberOfSectionsAfterUpdates: Int!
	var numberOfRowsAfterUpdates: [Int]!
	
	var insertedIndexPaths: [IndexPath] = []
	var deletedIndexPaths: [IndexPath] = []
	
	
	var movedIn_IndexPaths: [IndexPath] = []
	var movedOut_IndexPaths: [IndexPath] = []

	var insertedSections: [Int] = []
	var deletedSections: [Int] = []
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
		self.resetAllValues()
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		self.resetAllValues()
		super.tearDown()
	}

	
	func resetAllValues() {
		// Reset IndexPaths
		self.insertedIndexPaths = []
		self.deletedIndexPaths = []
		self.movedIn_IndexPaths = []
		self.movedOut_IndexPaths = []

		// Reset Sections
		self.insertedSections = []
		self.deletedSections = []
	}
	
	func beginUpdates() {
		self.resetAllValues()

		let numberOfSections = self.dataSource?.numberOfSections(in: self) ?? 0
		let numberOfRows = (0..<numberOfSections).map { self.dataSource?.tableView(self, numberOfRowsInSection: $0) ?? 0 }
		
		self.numberOfSectionsBeforeUpdates = numberOfSections
		self.numberOfRowsBeforeUpdates = numberOfRows

	}
	
	func endUpdates() {
		let numberOfSections = self.dataSource?.numberOfSections(in: self) ?? 0
		let numberOfRows = (0..<numberOfSections).map { self.dataSource?.tableView(self, numberOfRowsInSection: $0) ?? 0 }
		
		self.numberOfSectionsAfterUpdates = numberOfSections
		self.numberOfRowsAfterUpdates = numberOfRows
		
		//Check sections update
		let numberOfInsertedSectons = self.insertedSections.count
		let numberOfDeletedSectons = self.deletedSections.count
		
		XCTAssertEqual(self.numberOfSectionsAfterUpdates, self.numberOfSectionsBeforeUpdates + numberOfInsertedSectons - numberOfDeletedSectons, self.updateSectionsErrorMessageFor(inserted: numberOfInsertedSectons, deleted: numberOfDeletedSectons))
		
		var insertedIndexPaths = self.insertedIndexPaths
		var deletedIndexPaths = self.deletedIndexPaths
		var movedIn_IndexPaths = self.movedIn_IndexPaths
		var movedOut_IndexPaths = self.movedOut_IndexPaths
		
		while !insertedIndexPaths.isEmpty {
			let firstIndexPath = insertedIndexPaths.first!
			let sectionIndex = firstIndexPath.section
			let filterInserted = insertedIndexPaths.filter { $0.section == sectionIndex }
			let filterDeleted = deletedIndexPaths.filter { $0.section == sectionIndex }
			let filterMovedIn = movedIn_IndexPaths.filter { $0.section == sectionIndex }
			let filterMovedOut = movedOut_IndexPaths.filter { $0.section == sectionIndex }
		
			let errorMessage = self.updateRowsErrorMessageFor(section: sectionIndex, inserted: filterInserted.count, deleted: filterDeleted.count, movedIn: filterMovedIn.count, movedOut: filterMovedOut.count)
			
			XCTAssertEqual(self.numberOfRowsAfterUpdates[sectionIndex], self.numberOfRowsBeforeUpdates[sectionIndex] + filterInserted.count + filterMovedIn.count - filterDeleted.count - filterMovedOut.count, 		errorMessage)
			
			
			for indexPath in filterInserted {
				let index = insertedIndexPaths.firstIndex(of: indexPath)!
				insertedIndexPaths.remove(at: index)
			}
			
			for indexPath in filterDeleted {
				let index = deletedIndexPaths.firstIndex(of: indexPath)!
				deletedIndexPaths.remove(at: index)
			}
			
			for indexPath in filterMovedIn {
				let index = movedIn_IndexPaths.firstIndex(of: indexPath)!
				movedIn_IndexPaths.remove(at: index)
			}
			
			for indexPath in filterMovedOut {
				let index = movedOut_IndexPaths.firstIndex(of: indexPath)!
				movedOut_IndexPaths.remove(at: index)
			}
			
		}
		
		while !deletedIndexPaths.isEmpty {
			let firstIndexPath = deletedIndexPaths.first!
			let sectionIndex = firstIndexPath.section
			let filterDeleted = deletedIndexPaths.filter { $0.section == sectionIndex }
			let filterMovedIn = movedIn_IndexPaths.filter { $0.section == sectionIndex }
			let filterMovedOut = movedOut_IndexPaths.filter { $0.section == sectionIndex }

			let errorMessage = self.updateRowsErrorMessageFor(section: sectionIndex, inserted: 0, deleted: filterDeleted.count, movedIn: filterMovedIn.count, movedOut: filterMovedOut.count)
			
			XCTAssertEqual(self.numberOfRowsAfterUpdates[sectionIndex], self.numberOfRowsBeforeUpdates[sectionIndex] + filterMovedIn.count - filterDeleted.count - filterMovedOut.count, errorMessage)
			
			for indexPath in filterDeleted {
				let index = deletedIndexPaths.firstIndex(of: indexPath)!
				deletedIndexPaths.remove(at: index)
			}
			
			for indexPath in filterMovedIn {
				let index = movedIn_IndexPaths.firstIndex(of: indexPath)!
				movedIn_IndexPaths.remove(at: index)
			}
			
			for indexPath in filterMovedOut {
				let index = movedOut_IndexPaths.firstIndex(of: indexPath)!
				movedOut_IndexPaths.remove(at: index)
			}
			
		}
		
		while !movedIn_IndexPaths.isEmpty {
			let firstIndexPath = movedIn_IndexPaths.first!
			let sectionIndex = firstIndexPath.section
			let filterMovedIn = movedIn_IndexPaths.filter { $0.section == sectionIndex }
			let filterMovedOut = movedOut_IndexPaths.filter { $0.section == sectionIndex }
			
			let errorMessage = self.updateRowsErrorMessageFor(section: sectionIndex, inserted: 0, deleted: 0, movedIn: filterMovedIn.count, movedOut: filterMovedOut.count)
			
			XCTAssertEqual(self.numberOfRowsAfterUpdates[sectionIndex], self.numberOfRowsBeforeUpdates[sectionIndex] + filterMovedIn.count - filterMovedOut.count, errorMessage)
			
			for indexPath in filterMovedIn {
				let index = movedIn_IndexPaths.firstIndex(of: indexPath)!
				movedIn_IndexPaths.remove(at: index)
			}
			
			for indexPath in filterMovedOut {
				let index = movedOut_IndexPaths.firstIndex(of: indexPath)!
				movedOut_IndexPaths.remove(at: index)
			}
		}

		while !movedOut_IndexPaths.isEmpty {
			let firstIndexPath = movedOut_IndexPaths.first!
			let sectionIndex = firstIndexPath.section
			let filterMovedOut = movedOut_IndexPaths.filter { $0.section == sectionIndex }
			
			let errorMessage = self.updateRowsErrorMessageFor(section: sectionIndex, inserted: 0, deleted: 0, movedIn: 0, movedOut: filterMovedOut.count)
			
			XCTAssertEqual(self.numberOfRowsAfterUpdates[sectionIndex], self.numberOfRowsBeforeUpdates[sectionIndex] - filterMovedOut.count, 	errorMessage)
			
			for indexPath in filterMovedOut {
				let index = movedOut_IndexPaths.firstIndex(of: indexPath)!
				movedOut_IndexPaths.remove(at: index)
			}
			
		}
		
	}
	
	func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		self.insertedIndexPaths.append(contentsOf: indexPaths)
	}
	
	func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		self.deletedIndexPaths.append(contentsOf: indexPaths)
	}
	
	func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		self.movedIn_IndexPaths.append(newIndexPath)
		self.movedOut_IndexPaths.append(indexPath)
	}
	
	func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		self.insertedSections.append(contentsOf: sections)
	}
	
	func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		self.deletedSections.append(contentsOf: sections)
	}
	
	func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
		self.beginUpdates()
		updates?()
		self.endUpdates()
	}
	
	func updateSectionsErrorMessageFor(inserted: Int, deleted: Int) -> String {
		let message =
		"""
			Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid update: invalid number of sections. The number of sections contained in the table view after the update \(self.numberOfSectionsAfterUpdates ?? 0) must be equal to the number of sections contained in the table view before the update \(self.numberOfSectionsBeforeUpdates ?? 0), plus or minus the number of sections inserted or deleted (\(inserted) inserted, \(deleted) deleted).
		"""
		return message
	}
	
	func updateRowsErrorMessageFor(section: Int, inserted: Int, deleted: Int, movedIn: Int, movedOut: Int) -> String {
		let message =
		"""
			Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid update: invalid number of rows in section \(section). The number of rows contained in an existing section after the update \(self.numberOfRowsAfterUpdates[section]) must be equal to the number of rows contained in that section before the update \(self.numberOfRowsBeforeUpdates[section]), plus or minus the number of rows inserted or deleted from that section (\(inserted) inserted, \(deleted) deleted) and plus or minus the number of rows moved into or out of that section (\(movedIn) moved in, \(movedOut) moved out).
		"""
		return message
	}

	
}
