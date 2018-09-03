//
//  ModelTestsBasicFiltered.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
import Model

class ModelTestsBasicSorted: ModelTestsBasic {
    
    override func setUp() {
		self.sort = { $0.firstName < $1.firstName }

        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testPrint() {
		let names = self.model.allEntitiesForExport(sortedBy: nil).map { $0.firstName }
		
		for name in names {
			print("\(name)\n")

		}
	}
	
//	func testInsertAtFirstSorted() {
//		let dic = ["id":232,"first_name":"Epo","last_name":"AppleSeed","email":"jhon@apple.com","gender":"male","country":"USA"] as [String : Any]
//		let member1 = Member(data: dic)!
//		var member2 = member1
//		member2.firstName = "Eqo"
//		
//		var member3 = member1
//		member3.firstName = "Euo"
//
//		self.delegateExpect =  expectation(description: "insert at First Expect")
//		self.model.insertAtFirst(member1, applySort: true)
//		waitForExpectations(timeout: 5, handler: nil)
//		
//		let member1IndexPath = self.model.indexPath(of: member1)
//		
//		XCTAssertEqual(member1IndexPath?.row, 4)
//		
//		self.delegateExpect =  expectation(description: "insert at First Expect")
//		self.model.insertAtFirst(member2, applySort: true)
//		waitForExpectations(timeout: 5, handler: nil)
//		
//		let member2IndexPath = self.model.indexPath(of: member2)
//		
//		XCTAssertEqual(member2IndexPath?.row, 5)
//
//		self.delegateExpect =  expectation(description: "insert at First Expect")
//		self.model.insertAtFirst(member3, applySort: true)
//		waitForExpectations(timeout: 5, handler: nil)
//		
//		let member3IndexPath = self.model.indexPath(of: member3)
//		
//		XCTAssertEqual(member3IndexPath?.row, 6)
//
//		
//		/*
//		Alan
//		
//		Barty
//		
//		Davis
//		
//		Emma
//		
//		Gracie
//		
//		Heloise
//		
//		Jeri
//		
//		Osbourne
//		
//		Sadye
//		
//		Trula
//
//		*/
//		
//	}
//	
//	
//	override func model(didChange entities: [EntityProtocol], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
//		if type == .insert {
//			if let entity = entities.first as? Member {
//				switch entity.firstName {
//				case "Epo":
//					XCTAssertEqual(newIndexPaths!.first!.row, 4)
//				case "Eqo":
//					XCTAssertEqual(newIndexPaths!.first!.row, 5)
//				case "Euo":
//					XCTAssertEqual(newIndexPaths!.first!.row, 6)
//					
//					default: break
//					
//				}
//			}
//		}
//		else {
//			super.model(didChange: entities, at: indexPaths, for: type, newIndexPaths: newIndexPaths)
//		}
//	}
        
}
