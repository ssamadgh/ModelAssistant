//
//  ModelTestsWithSectionFiltered.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest

class ModelTestsWithSectionFiltered: ModelTestsWithSection {
    
    override func setUp() {
		self.filter = { $0.fullName.contains("a")}

        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
}
