//
//  ModelTestsBasicFiltered.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
import ModelAssistant

class ModelTestsBasicSorted: ModelTestsBasic {

	override func configureModel(sectionKey: String?) {
		super.configureModel(sectionKey: sectionKey)
		self.model.sortEntities = { $0.firstName < $1.firstName }
	}

	func testPrint() {
		let names = self.model.getAllEntities(sortedBy: nil).map { $0.firstName }

		for name in names {
			print("\(name)\n")

		}
	}

}
