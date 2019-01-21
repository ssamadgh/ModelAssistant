/**
SectionsManager.swift
ModelAssistant

Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import Foundation

struct SectionsManager<Entity: MAEntity & Hashable> {

	var sectionIndexTitles: [String] {
		return self.sections.compactMap { $0.indexTitle }.removingDuplicates()
	}

	var numberOfSections: Int {
		guard !self.isEmpty else { return 0 }
		return sections.count
	}

	func numberOfEntites(at sectionIndex: Int) -> Int {
		guard !self.isEmpty, let section = self[sectionIndex] else { return 0 }
		return section.numberOfEntities
	}

	var isEmpty: Bool {
		return sections.isEmpty
	}

	private (set) var sections: [SectionInfo<Entity>] = []

	private var nameSet: Set<String> {
		return Set(self.sections.compactMap { $0.name })
	}

	mutating func insert(_ entities: [Entity], toSectionWithName sectionName: String?) -> (updated: (indexPaths: [IndexPath], entities: [Entity])?, inserted:  (indexPaths: [IndexPath], entities: [Entity])?) {

		var sectionIndex = 0
		if let sectionName = sectionName {
			sectionIndex = self.firstIndexOfSection(withSectionName: sectionName)!
		}

		return insert(entities, toSectionAt: sectionIndex)
	}

	mutating func insert(_ entities: [Entity], toSectionAt sectionIndex: Int) -> (updated: (indexPaths: [IndexPath], entities: [Entity])?, inserted:  (indexPaths: [IndexPath], entities: [Entity])?) {

		guard sectionIndex < numberOfSections else { return (updated: nil, inserted: nil)}

		let result = self.sections[sectionIndex].append(contentsOf: entities)

		let updatedIndexPaths: [IndexPath] = result.updated?.indexes.map { IndexPath(row: $0, section: sectionIndex) } ?? []
		let insertedIndexPaths: [IndexPath] = result.inserted?.indexes.map { IndexPath(row: $0, section: sectionIndex) } ?? []

		let updated = result.updated != nil ? (indexPaths: updatedIndexPaths, entities: result.updated!.entities) : nil
		let inserted = result.inserted != nil ? (indexPaths: insertedIndexPaths, entities: result.inserted!.entities) : nil

		return (updated: updated, inserted: inserted)
	}

	mutating func append(_ section: SectionInfo<Entity>) {
		self.sections.append(section)
	}

	mutating func append<S>(contentsOf sections: S) where S: Sequence, S.Element == SectionInfo<Entity> {
		self.sections.append(contentsOf: sections)
	}


	mutating func insert(_ section: SectionInfo<Entity>, at index: Int) {
		self.sections.insert(section, at: index)
	}

	mutating func insert(_ entity: Entity, at indexPath: IndexPath) {
		self.sections[indexPath.section].insert(entity, at: indexPath.row)
	}

	mutating func update(_ entity: Entity, at indexPath: IndexPath) {
		self.sections[indexPath.section][indexPath.row] = entity
	}

	@discardableResult
	mutating func remove(at indexPath: IndexPath) -> Entity {
		return self.sections[indexPath.section].remove(at: indexPath.row)
	}

	@discardableResult
	mutating func remove(at sectionIndex: Int) -> SectionInfo<Entity> {
		return self.sections.remove(at: sectionIndex)
	}

	mutating func removeAll() {
		self.sections.removeAll()
	}

	func indexPath(of entity: Entity, withSectionName sectionName: String?) -> IndexPath? {

		guard !self.sections.isEmpty else { return nil }

		if sectionName == nil {
			if let row = self.sections[0].firstIndex(of: entity) {
				return IndexPath(row: row, section: 0)
			}
		}
		else {
			if let sectionIndex = self.firstIndexOfSection(withSectionName: sectionName!), let row = self.sections[sectionIndex].firstIndex(of: entity) {
				return IndexPath(row: row, section: sectionIndex)
			}
		}

		//Some times the entity has indexPath but the above solutions cant find it.
		guard let section = (self.sections.first { $0.contains(entity) }) else { return nil }

		let indexPath = IndexPath(row: section.firstIndex(of: entity)!, section: self.firstIndex(of: section)!)

		return indexPath
	}

	func indexPath(of entity: Entity, atSection sectionIndex: Int) -> IndexPath? {

		if let row = self.sections[sectionIndex].firstIndex(of: entity) {
			return IndexPath(row: row, section: sectionIndex)
		}

		return nil
	}


	func firstIndex(of section: SectionInfo<Entity>) -> Int? {
		return self.sections.firstIndex(of: section)
	}

	func firstIndexOfSection(withSectionName sectionName: String) -> Int? {
		return self.sections.firstIndex { $0.name == sectionName }
	}

	subscript(index: Int) -> SectionInfo<Entity>? {
		get {
			if index < self.numberOfSections {
				return self.sections[index]
			}
			else {
				return nil
			}
		}

		set {
			if index < self.numberOfSections {
				if newValue != nil {
					self.sections[index] = newValue!
				}
			}
		}
	}

	subscript(indexPath: IndexPath) -> Entity? {
		get {
			if indexPath.section < self.numberOfSections {
				let section = self.sections[indexPath.section]

				if indexPath.row < section.numberOfEntities {
					return section[indexPath.row]
				}
				else {
					return nil
				}

			}
			else {
				return nil
			}
		}

		set {
			if indexPath.section < self.numberOfSections {
				let numberOfSectionEntities = self.sections[indexPath.section].numberOfEntities

				if indexPath.row < numberOfSectionEntities {
					if newValue != nil {
						self.sections[indexPath.section][indexPath.row] = newValue!
					}
				}


			}

		}


	}

	func containsSection(with sectionName: String) -> Bool {
		return self.nameSet.contains(sectionName)
	}

	func entities(atSection sectionIndex: Int) -> [Entity] {
		return self.sections[sectionIndex].entities
	}

	mutating func remvoeAllEntities(atSection sectionIndex: Int) {
		self.sections[sectionIndex].entities.removeAll()
	}

	mutating func newSection(with entities: [Entity], name: String, indexTitle: String?) -> SectionInfo<Entity> {
		let section = SectionInfo(entities: entities, name: name, indexTitle: indexTitle)
		return section
	}

	mutating func sortEntities(atSection sectionIndex: Int, by sort: ((Entity, Entity) -> Bool)) -> (oldIndexPaths: [IndexPath], newIndexPaths: [IndexPath]) {
		let result = self[sectionIndex]?.sort(by: sort)
		let oldIndexPaths = result?.oldIndexes.map { IndexPath(row: $0, section: sectionIndex) } ?? []
		let newIndexPaths = result?.newIndexes.map { IndexPath(row: $0, section: sectionIndex) } ?? []
		return (oldIndexPaths: oldIndexPaths, newIndexPaths: newIndexPaths)
	}

	mutating func sortSections(by sort: ((SectionInfo<Entity>, SectionInfo<Entity>) -> Bool)) -> (oldIndexes: [Int], newIndexes: [Int]) {
		let oldSections = self.sections
		self.sections.sort(by: sort)
		let oldIndexes = Array(0..<oldSections.count)
		let newIndexes = oldSections.map { self.sections.index(of: $0) }
		return (oldIndexes: oldIndexes, newIndexes:newIndexes as! [Int])
	}

	func filteredEntities(atSection sectionIndex: Int, with filter: ((Entity) -> Bool)) -> [Entity] {
		return self[sectionIndex]?.filter(by: filter) ?? []
	}

	func filteredEntities(with filter: @escaping ((Entity) -> Bool)) -> [Entity] {
		let containSections = self.sections.filter { $0.entities.contains(where: filter) }
		return containSections.flatMap { $0.filter(by: filter) }
	}

	func allEntities() -> [Entity]  {
		return self.sections.flatMap { $0.entities }
	}

	func firstSectionIndex(withSectionIndexTitle title: String) -> Int {
		return self.sections.firstIndex { $0.indexTitle == title }!
	}

}


extension SectionsManager where Entity: MAFaultable {

	mutating func fault(at sectionIndex: Int, in range: Range<Int>) {
		self.sections[sectionIndex].fault(in: range)
	}

	mutating func fire(at sectionIndex: Int, in range: Range<Int>) {
		self.sections[sectionIndex].fire(in: range)
	}

}
