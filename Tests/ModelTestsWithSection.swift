//
//  ModelTestsWithSection.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
@testable import ModelAssistant

class ModelTestsWithSection: ModelTestsBasic {

	override func configureModel(sectionKey: String?) {
		super.configureModel(sectionKey: "country")
	}

	override func testModelAfterFetch() {
		var members = self.members!

		if let filter = self.filter {
			members = self.members.filter(filter)
		}


		let countryArry = members.compactMap { $0.country }
		let countrySet = Set(countryArry)
		XCTAssertEqual(self.model.numberOfSections, countrySet.count)

		for country in countrySet {
			var filtered = members.filter { $0.country == country }
			if let sort = self.sortEntities {
				filtered = filtered.sorted(by: sort)
			}

			let index = self.model.indexOfSection(withSectionName: country)!
			let section = self.model.section(at: index)
			XCTAssertEqual(section!.numberOfEntities, filtered.count)
			XCTAssertEqual(Set(section!.entities), Set(filtered))
		}
	}
	
	override func testInsertDifferentEntities() {
		
	}


}
