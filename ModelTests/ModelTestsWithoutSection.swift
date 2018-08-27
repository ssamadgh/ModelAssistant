//
//  ModelTests.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
@testable import Model

class ModelTestsWithoutSection: XCTestCase, ModelDelegate {
	
	var delegateCalledBalance = 0
	
	var model: Model<Member>!
	var members: [Member]!
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
		self.model = Model()
		self.model.delegate = self
		
		self.members = self.entities(forFileWithName: "MOCK_DATA_10")
		
		let expect = expectation(description: "insertExpect")
		self.model.fetch(members) {
			
			expect.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		XCTAssert(self.delegateCalledBalance == 0)
		self.model = nil
		self.members = nil
		super.tearDown()
	}
	
	func entities(forFileWithName fileName: String) -> [Member] {
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: fileName, withExtension: "json")!
		let json = try! Data(contentsOf: url)
		
		let decoder = JSONDecoder()
		let members = try! decoder.decode([Member].self, from: json)
		return members
	}
	
	
	func testCountOfEntities() {
		XCTAssertEqual(self.model.numberOfWholeEntities, 10)
	}
	
	func testInsertSameEntities() {
		let beforeNumberOfEntities = self.model.numberOfWholeEntities
		let beforeNumberOfFetchedEntities = self.model.numberOfFetchedEntities


		let expect = expectation(description: "insertExpect")
		self.model.insert(members) {

			expect.fulfill()
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
		
		let expect = expectation(description: "insertExpect")
		self.model.insert(members) {
			
			expect.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
		let afterNumberOfEntities = self.model.numberOfWholeEntities
		let afterNumberOfFetchedEntities = self.model.numberOfFetchedEntities
		XCTAssertEqual(afterNumberOfEntities, beforeNumberOfEntities + 20)
		XCTAssertEqual(afterNumberOfFetchedEntities, beforeNumberOfFetchedEntities + 10)
	}
	
	func testGetIndexPath() {
		let indexPath1 = self.model.indexPath(of: self.members.first!)
		XCTAssertNotNil(indexPath1)
		
		let id = 3
		let indexPath2 = self.model.indexPathOfEntity(withId: id)
		XCTAssertNotNil(indexPath2)

		let entity = self.model[indexPath2!]
		XCTAssertEqual(entity?.id, id)
	}
	
	func testMemberEqualable() {
		let dic1 = ["id":232,"first_name":"Emma","last_name":"McGinty","email":"emcginty0@wp.com","gender":"Female","country":"China"] as [String : Any]
		let dic2 = ["id":232,"first_name":"Emilia","last_name":"McGinty","email":"emcginty0@wp.com","gender":"Female","country":"China"] as [String : Any]
		
		let member1 = Member(data: dic1)

		let member2 = Member(data: dic2)
		
		XCTAssertNotEqual(member1, member2)
	}
	
	func testSortAndReorder() {
		self.model.sort = { $0.lastName < $1.lastName }
		
		let expect = expectation(description: "Reorder")
		self.model.reorder {
			expect.fulfill()
		}
		waitForExpectations(timeout: 5, handler: nil)
	}
	
//	func testPerformanceExample() {
//		// This is an example of a performance test case.
//		self.measure {
//			// Put the code you want to measure the time of here.
//		}
//	}
	
	func modelWillChangeContent(for type: ModelChangeType) {
		XCTAssert(self.delegateCalledBalance >= 0)
		self.delegateCalledBalance += 1
	}
	
	func modelDidChangeContent(for type: ModelChangeType) {
		XCTAssert(self.delegateCalledBalance > 0)
		self.delegateCalledBalance -= 1
	}
	
	func model(didChange entities: [EntityProtocol], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
		switch type {
		case .insert:
			XCTAssertNil(indexPaths)
			XCTAssertNotNil(newIndexPaths)
			XCTAssertNotNil(entities)

		case .delete:
			XCTAssertNotNil(indexPaths)
			XCTAssertNil(newIndexPaths)
			XCTAssertNotNil(entities)
			
		case .move:
			XCTAssertNotNil(indexPaths)
			XCTAssertNotNil(newIndexPaths)
			XCTAssertNotNil(entities)

		case .update:
			XCTAssertNotNil(indexPaths)
			XCTAssertNil(newIndexPaths)
			XCTAssertNotNil(entities)

		}
	}
	
	func model(didChange sectionInfo: ModelSectionInfo, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) {
		switch type {
		case .insert:
			XCTAssertNil(sectionIndex)
			XCTAssertNotNil(newSectionIndex)
			XCTAssertNotNil(sectionInfo)
			
		case .delete:
			XCTAssertNotNil(sectionIndex)
			XCTAssertNil(newSectionIndex)
			XCTAssertNotNil(sectionInfo)
			
		case .move:
			XCTAssertNotNil(sectionIndex)
			XCTAssertNotNil(newSectionIndex)
			XCTAssertNotNil(sectionInfo)
			
		case .update:
			XCTAssertNotNil(sectionIndex)
			XCTAssertNil(newSectionIndex)
			XCTAssertNotNil(sectionInfo)
			
		}

	}
	
}
