//
//  ModelTestsWithSectionSorted.swift
//  ModelTests
//
//  Created by Seyed Samad Gholamzadeh on 8/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import XCTest
@testable import Model

class ModelTestsWithSectionSorted: ModelTestsWithSection {

	override func configureModel(sectionKey: String?) {
		super.configureModel(sectionKey: sectionKey)
		self.model.sortSections = { $0.name < $1.name }
		self.model.sortEntities = { $0.firstName < $1.firstName }
	}


	func testSectionIndexTitle() {
		let sectionIndexTitles = self.model.sectionIndexTitles
		let sections = self.model.sections
		let titles = Set(sections.compactMap { self.model.sectionIndexTitle(forSectionName: $0.name) })
		XCTAssertEqual(titles, Set(sectionIndexTitles))
	}

	func testSectionForSectionIndexTitle() {
		let sectionNames = self.model.sections.compactMap { $0.name }
		let indexTitles = self.model.sectionIndexTitles

		print("sectoinNames are \(sectionNames) and indexTitles are \(indexTitles)")

		/*

			sectoinNames are ["China", "Mauritius", "Nigeria", "Palestinian Territory", "Poland", "Russia", "Saudi Arabia", "Senegal", "Ukraine"]
			and

			indexTitles are ["C", "M", "N", "P", "R", "S", "U"]

		*/

		let section = self.model.section(forSectionIndexTitle: "P", at: indexTitles.firstIndex(of: "P")!)

		XCTAssertEqual(section, sectionNames.firstIndex(of: "Palestinian Territory"))

	}

}
