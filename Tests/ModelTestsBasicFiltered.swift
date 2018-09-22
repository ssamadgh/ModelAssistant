//
//  ModelTestsBasicFiltered.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest

class ModelTestsBasicFiltered: ModelTestsBasic {
	
	override func configureModel(sectionKey: String?) {
		super.configureModel(sectionKey: sectionKey)
		self.model.filter = { $0.fullName.contains("a")}
	}
	
	
    
}
