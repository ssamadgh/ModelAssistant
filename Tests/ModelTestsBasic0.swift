//
//  ModelTestsBasic0.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 9/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
@testable import Model

class ModelTestsBasic0: XCTestCase, ModelDelegate, TestTableViewDataSource {
	
	var delegateCalledBalance = 0
	var delegateExpect: XCTestExpectation!
	var updateDelegateExpect: XCTestExpectation!
	var model: Model<Member>!
	var members: [Member]!
	
	var sortEntities: ((Member, Member) -> Bool)?
	var sortSections: ((SectionInfo<Member>, SectionInfo<Member>) -> Bool)?
	var filter: ((Member) -> Bool)?
	
	var tableView: TestTableView!

    override func setUp() {
		super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		self.configureTableView()
		self.configureModel(sectionKey: nil)
		self.checkSortAndFilterOfModel()
		self.fetchEntities()
    }
	
	func configureTableView() {
		self.tableView = TestTableView()
		self.tableView.dataSource = self
	}

	func configureModel(sectionKey: String?) {
		self.model = Model(sectionKey: sectionKey)
		self.model.delegate = self
	}
	
	func checkSortAndFilterOfModel() {
		self.sortEntities = self.model.sortEntities
		self.sortSections = self.model.sortSections
		self.filter = self.model.filter
	}
	
	func fetchEntities() {
		self.setMembers()
		let expect = expectation(description: "insertExpect")
		self.model.fetch(members) {
			XCTAssertEqual(self.members.count, self.model.numberOfFetchedEntities)
			if let filter = self.filter {
				let filteredCount = self.members.filter(filter).count
				XCTAssertEqual(self.model.numberOfWholeEntities, filteredCount)
				
			}
			else {
				let numberOfWholeEntities = self.model.numberOfWholeEntities
				let numberOfFetchedEntities = self.model.numberOfFetchedEntities
				XCTAssertEqual(numberOfWholeEntities, numberOfFetchedEntities, "number of whole entities should be equal to number of fetched enities")
			}
			
			expect.fulfill()
		}
		
		waitForExpectations(timeout: 20, handler: nil)
	}

	func setMembers() {
		self.members = self.entities(forFileWithName: "MOCK_DATA_10")
	}

	func entities(forFileWithName fileName: String) -> [Member] {
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: fileName, withExtension: "json")!
		let json = try! Data(contentsOf: url)
		
		let decoder = JSONDecoder()
		let members = try! decoder.decode([Member].self, from: json)
		return members
	}


    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
		XCTAssert(self.delegateCalledBalance == 0)
		self.model = nil
		self.members = nil
		self.tableView = nil
		super.tearDown()
    }

	//MARK: - TestTableViewDataSource Methods

	func numberOfSections(in tableView: TestTableViewProtocol) -> Int {
		return self.model.numberOfSections
	}
	
	func tableView(_ tableView: TestTableViewProtocol, numberOfRowsInSection section: Int) -> Int {
		return self.model.numberOfEntites(at: section)
	}
	
	
	//MARK: - Model delegate Methods
	
	func modelWillChangeContent() {
		XCTAssert(self.delegateCalledBalance >= 0)
		self.delegateCalledBalance += 1
		self.tableView.beginUpdates()
	}
	
	func modelDidChangeContent() {
		self.tableView.endUpdates()
		XCTAssert(self.delegateCalledBalance > 0)
		self.delegateCalledBalance -= 1
		self.delegateExpect.fulfill()
	}
	
	func model<Entity>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) where Entity : EntityProtocol, Entity : Hashable {
		switch type {
		case .insert:
			XCTAssertNil(indexPaths)
			XCTAssertNotNil(newIndexPaths)
			XCTAssertNotNil(entities)
			self.tableView.insertRows(at: newIndexPaths!, with: .automatic)
			
		case .delete:
			XCTAssertNotNil(indexPaths)
			XCTAssertNil(newIndexPaths)
			XCTAssertNotNil(entities)
			self.tableView.deleteRows(at: indexPaths!, with: .automatic)
			
		case .move:
			XCTAssertNotNil(indexPaths)
			XCTAssertNotNil(newIndexPaths)
			XCTAssertNotNil(entities)
			for i in 0..<indexPaths!.count {
				self.tableView.moveRow(at: indexPaths![i], to: newIndexPaths![i])
			}
			
		case .update:
			XCTAssertNotNil(indexPaths)
			XCTAssertNil(newIndexPaths)
			XCTAssertNotNil(entities)
			self.updateDelegateExpect?.fulfill()
			
		}
	}
	
	func model<Entity>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) where Entity : EntityProtocol, Entity : Hashable {
		switch type {
		case .insert:
			XCTAssertNil(sectionIndex)
			XCTAssertNotNil(newSectionIndex)
			XCTAssertNotNil(sectionInfo)
			self.tableView.insertSections(IndexSet(integer: newSectionIndex!), with: .automatic)
			
		case .delete:
			XCTAssertNotNil(sectionIndex)
			XCTAssertNil(newSectionIndex)
			XCTAssertNotNil(sectionInfo)
			self.tableView.deleteSections(IndexSet(integer: sectionIndex!), with: .automatic)

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
