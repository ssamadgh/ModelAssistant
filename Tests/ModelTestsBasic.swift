//
//  ModelTests.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
@testable import Model

class ModelTestsBasic: ModelTestsBasic0 {
	
	func testIndexOfEntityWithId() {
		let entity = Member(data: ["id":1])!
		let indexPath = self.model.indexPathOfEntity(withUniqueValue: entity.uniqueValue)
		XCTAssertNotNil(indexPath)
	}
	
	func testIndexOfEntity() {
		let entity = Member(data: ["id":1,"first_name":"Emma","last_name":"McGinty"])!
		let indexPath = self.model.indexPath(of: entity)
		XCTAssertNotNil(indexPath)
		
		let indexPathWithUniqueValue = self.model.indexPathOfEntity(withUniqueValue: entity.uniqueValue)
		
		XCTAssertEqual(indexPath, indexPathWithUniqueValue)
	}
	
	func testModelAfterFetch() {
		var members = self.members!
		
		if let filter = self.filter {
			members = members.filter(filter)
		}
		
		if let sort = self.sortEntities {
			members = members.sorted(by: sort)
		}
		
		XCTAssert(self.model.section(at: 0)!.name == "")
//		XCTAssert(self.model.section(at: 0)!.entities == members)
	}
	
	func testCountOfEntities() {
		if let filter = self.filter {
			let members = self.members.filter(filter)
			XCTAssertEqual(self.model.numberOfWholeEntities, members.count)
		}
		else {
			XCTAssertEqual(self.model.numberOfWholeEntities, self.members.count)
		}
	}
	
	func testGetIndexPath() {
		let indexPath1 = self.model.indexPath(of: self.members.first!)
		XCTAssertNotNil(indexPath1)
		
		let id = 3
		let indexPath2 = self.model.indexPathOfEntity(withUniqueValue: id)
		XCTAssertNotNil(indexPath2)
		
		let entity = self.model[indexPath2!]!
		XCTAssertEqual(entity.uniqueValue, id)
	}
	
	func testMemberEqualable() {
		let dic1 = ["id":232,"first_name":"Emma","last_name":"McGinty","email":"emcginty0@wp.com","gender":"Female","country":"China"] as [String : Any]
		let dic2 = ["id":232,"first_name":"Emilia","last_name":"McGinty","email":"emcginty0@wp.com","gender":"Female","country":"China"] as [String : Any]
		
		let member1 = Member(data: dic1)
		
		let member2 = Member(data: dic2)
		
		XCTAssertNotEqual(member1, member2)
	}
	
	func testSortAndReorder() {
		self.model.sortEntities = { $0.lastName < $1.lastName }
		
		self.delegateExpect = expectation(description: "Reorder")
		self.model.reorder {
		}
		
		waitForExpectations(timeout: 30, handler: nil)
	}
	
	func testInsertSameEntities() {
		let beforeNumberOfEntities = self.model.numberOfWholeEntities
		let beforeNumberOfFetchedEntities = self.model.numberOfFetchedEntities
		
		
		self.delegateExpect = expectation(description: "insertExpect")
		self.model.insert(members) {
			
			//			expect.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
		let afterNumberOfEntities = self.model.numberOfWholeEntities
		let afterNumberOfFetchedEntities = self.model.numberOfFetchedEntities
		XCTAssertEqual(afterNumberOfEntities, beforeNumberOfEntities)
		XCTAssertEqual(afterNumberOfFetchedEntities, beforeNumberOfFetchedEntities)
	}
	
	func testInsertDifferentEntities() {
		let beforeNumberOfEntities = self.model.numberOfWholeEntities
		let beforeNumberOfFetchedEntities = self.model.numberOfFetchedEntities
		
		let members = self.entities(forFileWithName: "MOCK_DATA_20")
		
		self.delegateExpect = expectation(description: "insertExpect")
		self.model.insert(members) {
			
		}
		
		waitForExpectations(timeout: 15, handler: nil)
		let afterNumberOfEntities = self.model.numberOfWholeEntities
		let afterNumberOfFetchedEntities = self.model.numberOfFetchedEntities
		
		let difSet = Set(self.members).subtracting(members).count
		if let filter = self.filter {
			let filtered = members.filter(filter)
			XCTAssertEqual(afterNumberOfEntities, beforeNumberOfEntities + filtered.count)
			XCTAssertEqual(afterNumberOfFetchedEntities, beforeNumberOfFetchedEntities + difSet)
		}
		else {
			XCTAssertEqual(afterNumberOfEntities, beforeNumberOfEntities + members.count)
			XCTAssertEqual(afterNumberOfFetchedEntities, beforeNumberOfFetchedEntities + difSet)
		}
	}
	
	func testInsertAtFirst() {
		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
		let member = Member(data: dic)!
		
		let indexPath = IndexPath(row: 0, section: 0)
		self.delegateExpect =  expectation(description: "insert at First Expect")
		self.model.insert(member, at: indexPath, completion: nil)
		waitForExpectations(timeout: 20, handler: nil)
		let memberIndexPath = self.model.indexPath(of: member)
		
		if self.sortEntities == nil {
			XCTAssertEqual(memberIndexPath, indexPath)
		}
		
	}
	
	func testInsertAtLast1() {
		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
		let member = Member(data: dic)!
		
		let lastSection = self.model.numberOfSections - 1
		let lastRow = self.model.numberOfEntites(at: lastSection)
		
		let indexPath = IndexPath(row: lastRow, section: lastSection)
		
		self.delegateExpect =  expectation(description: "insert at First Expect")
		self.model.insert(member, at: indexPath, completion: nil)
		waitForExpectations(timeout: 5, handler: nil)
		
		let memberIndexPath = self.model.indexPath(of: member)
		
		if self.sortEntities == nil {
			XCTAssertEqual(memberIndexPath, indexPath)
		}
		
	}
	
	func testInsertAtIndexPath() {
		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
		let member = Member(data: dic)!
		
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))
		
		let indexPath = IndexPath(row: row, section: section)
		self.delegateExpect =  expectation(description: "insert at indexPath Expect")
		self.model.insert(member, at: indexPath, completion: nil)
		waitForExpectations(timeout: 5, handler: nil)
		
		let memberIndexPath = self.model.indexPath(of: member)
		
		if self.sortEntities == nil {
			XCTAssertEqual(memberIndexPath, indexPath)
		}
	}
	
	func testInsertAtLast2() {
		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
		let member = Member(data: dic)!
		
		let section = self.model.numberOfSections - 1
		let row = self.model.numberOfEntites(at: section)
		
		let indexPath = IndexPath(row: row, section: section)
		self.delegateExpect =  expectation(description: "insert at Last Expect")
		self.model.insert(member, at: indexPath, completion: nil)
		waitForExpectations(timeout: 5, handler: nil)
		
		let memberIndexPath = self.model.indexPath(of: member)
		
		if self.sortEntities == nil {
			XCTAssertEqual(memberIndexPath, indexPath)
		}
	}
	
	func testInsertAtWrongIndexPath() {
//		let dic = ["id":232,"first_name":"Jhon","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
//		let member = Member(data: dic)!
//
//		let section = self.model.numberOfSections - 1
//		let row = self.model.numberOfEntites(at: section) + 1
//
//		let indexPath = IndexPath(row: row, section: section)
//		self.delegateExpect =  expectation(description: "insert at wrong indexPath Expect")
//		self.model.insert(member, at: indexPath, completion: nil)
//		waitForExpectations(timeout: 5, handler: nil)
//
//		let memberIndexPath = self.model.indexPath(of: member)
//
//		if self.sort == nil {
//			XCTAssertEqual(memberIndexPath, indexPath)
//		}
	}
	
	func testMoveEntityFromFirstToLast() {
		let oldIndexPath = IndexPath(row: 0, section: 0)
		
		let entity = self.model.entity(at: oldIndexPath)
		
		let newSection = self.model.numberOfSections-1
		let newRow = newSection == 0 ? self.model.numberOfEntites(at: newSection)-1 : self.model.numberOfEntites(at: newSection)
		let newIndexPath = IndexPath(row: newRow, section: newSection)
		
		let expect = expectation(description: "moving from first IndexPath to the last indexPath")
		self.model.moveEntity(at: oldIndexPath, to: newIndexPath, isUserDriven: true) {
			let currentIndexPath = self.model.indexPath(of: entity!)
			let expectedSection = self.model.numberOfSections-1
			let expectedRow = self.model.numberOfEntites(at: expectedSection) - 1
			let expectedIndexPath = IndexPath(row: expectedRow, section: expectedSection)
			
			XCTAssertEqual(currentIndexPath, expectedIndexPath)
			XCTAssertEqual(newIndexPath, expectedIndexPath)
			
			expect.fulfill()
		}
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testMoveEntityIsUserDriven() {
		let oldSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let oldRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: oldSection))))
		
		let oldIndexPath = IndexPath(row: oldRow, section: oldSection)
		
		let entity = self.model.entity(at: oldIndexPath)
		
		var newSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		if newSection == oldSection, self.model.numberOfEntites(at: newSection) == 1 {
			if self.model.numberOfSections > 1 {
				newSection += 1
			}
		}
		
		let newRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: newSection))))
		
		let newIndexPath = IndexPath(row: newRow, section: newSection)
		
		let expect = expectation(description: "moving from first IndexPath to the User derived indexPath")
		self.model.moveEntity(at: oldIndexPath, to: newIndexPath, isUserDriven: true) {
			let currentIndexPath = self.model.indexPath(of: entity!)
			let expectedIndexPath = newIndexPath
			XCTAssertEqual(currentIndexPath, expectedIndexPath)
			
			expect.fulfill()
		}
		waitForExpectations(timeout: 5, handler: nil)
		
	}
	
	func testMoveEntityNotUserDriven() {
		let oldSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let oldRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: oldSection))))
		
		let oldIndexPath = IndexPath(row: oldRow, section: oldSection)
		
		let entity = self.model.entity(at: oldIndexPath)
		
		var newSection = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		if newSection == oldSection, self.model.numberOfEntites(at: newSection) == 1 {
			if self.model.numberOfSections > 1 {
				newSection += 1
			}
		}
		
		let newRow = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: newSection))))
		
		let newIndexPath = IndexPath(row: newRow, section: newSection)
		
		self.delegateExpect =  expectation(description: "moving from first IndexPath to the user not derived indexPath")
		self.model.moveEntity(at: oldIndexPath, to: newIndexPath, isUserDriven: false, completion: nil)
		waitForExpectations(timeout: 5, handler: nil)
		let currentIndexPath = self.model.indexPath(of: entity!)
		let expectedIndexPath = newIndexPath
		XCTAssertEqual(currentIndexPath, expectedIndexPath)
		
	}
	
	func testUpdateIndexPath() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))
		
		let indexPath = IndexPath(row: row, section: section)
		
		let oldEntity = self.model[indexPath]
		
		self.updateDelegateExpect = expectation(description: "update IndexPath ")
		
		self.model!.update(at: indexPath, mutate: { (entity) in
			entity.firstName = "Gholam"
			entity.lastName = "Shishlool"
		}, completion: nil)
		
		waitForExpectations(timeout: 5, handler: nil)
		
		let newEntity = self.model[indexPath]
		
		XCTAssertNotEqual(newEntity, oldEntity)
	}
	
	func testRemoveAtIndexPath() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))
		
		let indexPath = IndexPath(row: row, section: section)
		
		self.delegateExpect = expectation(description: "remove IndexPath")
		
		var removedEntity: Member!
		self.model.remove(at: indexPath) { entity in
			removedEntity = entity
		}
		waitForExpectations(timeout: 5, handler: nil)
		
		if section < self.model.numberOfSections, row < self.model.numberOfEntites(at: section) {
			let entity = self.model.entity(at: indexPath)
			XCTAssertNotEqual(entity, removedEntity)
		}
	}
	
	func testRemoveAtIndexPathWithEmptySection() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		
		let oldSection = self.model[section]
		
		var numberOfEntities = self.model.numberOfEntites(at: section)
		let indexPath = IndexPath(row: 0, section: section)
		
		while numberOfEntities > 0 {
			self.delegateExpect = expectation(description: "remove IndexPath")
			self.model!.remove(at: indexPath) { entity in
			}
			waitForExpectations(timeout: 5, handler: nil)
			
			numberOfEntities -= 1
		}
		
		if self.model.numberOfSections > section {
			let currentSection = self.model[section]
			XCTAssertNotEqual(currentSection, oldSection)
		}
		
	}
		
	func testRemoveEntity() {
		let section = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		let row = Int(arc4random_uniform(UInt32(self.model.numberOfEntites(at: section))))
		
		let indexPath = IndexPath(row: row, section: section)
		
		let entity = self.model[indexPath]
		
		self.delegateExpect = expectation(description: "remove IndexPath")
		
		self.model.remove(entity!, completion: nil)
		
		waitForExpectations(timeout: 5, handler: nil)
		
		XCTAssertNil(self.model.indexPath(of: entity!))
	}
	
	func testRemoveSection() {
		let sectionIndex = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		
		let removedSection = self.model[sectionIndex]
		
		self.delegateExpect = expectation(description: "remove all entities at Section")
		
		self.model.removeSection(at: sectionIndex, completion: nil)
		
		waitForExpectations(timeout: 5, handler: nil)
		
		if sectionIndex < self.model.numberOfSections {
			let currentSection = self.model[sectionIndex]
			XCTAssertNotEqual(currentSection, removedSection)
		}
	}
	
	func testRemoveAll() {
		let expect = expectation(description: "wait for ending remove all")
		self.model.removeAll {
			XCTAssert(self.model.isEmpty)
			expect.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testSortSections() {
		self.delegateExpect = expectation(description: "remove all entities at Section")
		
		self.model.sortSections(by: { $0.name < $1.name }) {
			
		}
		
		waitForExpectations(timeout: 5, handler: nil)
		
		let firstIndex = 0
		
		let lastIndex = self.model.numberOfSections - 1
		
		let first = self.model[firstIndex]
		let last = self.model[lastIndex]
		
		if lastIndex == firstIndex {
			XCTAssert(last!.name == first!.name)
		}
		else {
			XCTAssert(last!.name > first!.name)
		}
		
		
	}
	
	func testFilterAtSection() {
		let sectionIndex = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		
		let entities = self.model.filteredEntities(atSection: sectionIndex, with: { $0.fullName.contains("g")})
		
		
		for entity in entities {
			XCTAssert(entity.fullName.contains("g"))
		}
	}
	
	func testAllEntitiesForExport() {
		var members = self.members!
		
		if filter != nil {
			members = self.members.filter(filter!)
		}
		
		let entities = self.model.getAllEntities(sortedBy: {$0.lastName < $1.lastName})
		XCTAssertEqual(entities.count, members.count)
	}
	
	func testIndexOfSection() {
		let sectionIndex = Int(arc4random_uniform(UInt32(self.model.numberOfSections - 1)))
		
		let section = self.model[sectionIndex]
		
		XCTAssertEqual(self.model.index(of: section!), sectionIndex)
	}
	
	//MARK: - Performance Checking
	
	func testPerformanceindexPathOfEntity() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
			let entity = Member(data: ["id":1,"first_name":"Emma","last_name":"McGinty"])!
			//			let indexPath = self.model.indexPath(of: entity)
			_ = self.model.indexPathOfEntity(withUniqueValue: entity.uniqueValue)
			
		}
	}
	
	
}

