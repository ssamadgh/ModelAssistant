//
//  ModelTestPagedDatabase.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 9/1/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest

class ModelTestPagedDatabase: ModelTestsBasic {

	override func configureModel(sectionKey: String?) {
		super.configureModel(sectionKey: sectionKey)
		self.model.fetchBatchSize = 5
	}

	override func setMembers() {
		self.members = self.entities(forFileWithName: "MOCK_DATA_20_0")
	}


	func testPagedInsert() {

		var endOfFetchData = false
		var minorIndex = ""
		while !endOfFetchData {
			let nextIndex = self.model.nextFetchIndex
			let members = self.entities(forFileWithName: "MOCK_DATA_20_\(nextIndex)\(minorIndex)")

			self.delegateExpect = expectation(description: "insert entities of page \(nextIndex)")
			self.model.insert(members, completion: nil)
			wait(for: [self.delegateExpect], timeout: 5)
			if members.count == self.model.fetchBatchSize {
				XCTAssert(self.model.nextFetchIndex == nextIndex + 1)
				XCTAssert(self.model.numberOfWholeEntities == (nextIndex + 1)*self.model.fetchBatchSize)
				minorIndex = ""
			}
			else {
				XCTAssert(self.model.nextFetchIndex == nextIndex)
				XCTAssert(self.model.numberOfWholeEntities == (nextIndex)*self.model.fetchBatchSize + members.count)
				minorIndex = "_2"
			}

			if members.isEmpty {
				endOfFetchData = true
			}
		}
	}


	override func testInsertSameEntities() {

	}

	override func testInsertDifferentEntities() {

	}

}
