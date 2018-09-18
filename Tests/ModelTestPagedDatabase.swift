//
//  ModelTestPagedDatabase.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 9/1/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest

class ModelTestPagedDatabase: ModelTestsBasic {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		self.model.fetchBatchSize = 5
    }
	
	override func setMembers() {
		self.members = self.entities(forFileWithName: "MOCK_DATA_20_0")
	}
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	
	func testPagedInsert() {
		
//		var endOfFetchData = false
//		var minorIndex = ""
//		while !endOfFetchData {
//			let nextIndex = self.model.nextIndex
//			let members = self.entities(forFileWithName: "MOCK_DATA_20_\(nextIndex)\(minorIndex)")
//			
//			self.delegateExpect = expectation(description: "insert entities of page \(nextIndex)")
//			self.model.insert(members)
//			waitForExpectations(timeout: 5, handler: nil)
//			if members.count == self.model.fetchBatchSize {
//				XCTAssert(self.model.nextIndex == nextIndex + 1)
//				XCTAssert(self.model.numberOfFetchedEntities == (nextIndex + 1)*self.model.fetchBatchSize)
//				minorIndex = ""
//			}
//			else {
//				XCTAssert(self.model.nextIndex == nextIndex)
//				XCTAssert(self.model.numberOfFetchedEntities == (nextIndex)*self.model.fetchBatchSize + members.count)
//				minorIndex = "_2"
//			}
//			
//			if members.isEmpty {
//				endOfFetchData = true
//			}
//		}

	}
	
	override func testInsertSameEntities() {
		
	}
	
	override func testInsertDifferentEntities() {
		
	}
	
}
