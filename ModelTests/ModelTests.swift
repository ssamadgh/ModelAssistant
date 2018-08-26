//
//  ModelTests.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
@testable import Model

class ModelTests: XCTestCase {
	
	var model: Model<Member>!
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		self.model = Model()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
		self.model = nil
        super.tearDown()
    }
	
	func entities(forFileWithName fileName: String) -> [Member] {
		let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
		let json = try! Data(contentsOf: url)
		
		let decoder = JSONDecoder()
		let members = try! decoder.decode([Member].self, from: json)
		return members
	}
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		
		
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
