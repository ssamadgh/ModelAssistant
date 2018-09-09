//
//  SectionsManager.swift
//  MyModelLibrary
//
//  Created by Seyed Samad Gholamzadeh on 8/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

struct SectionsManager<Entity: EntityProtocol & Hashable> {
	
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
	
	private (set) var sections: [SectionInfo<Entity>] = [] {
		didSet {
			self.nameSet = Set(self.sections.compactMap { $0.name })
		}
	}

	private var nameSet: Set<String> = []
	
	mutating func insert(_ entities: [Entity], toSectionWithName sectionName: String?) -> (updated: (indexPaths: [IndexPath], entities: [Entity])?, inserted:  (indexPaths: [IndexPath], entities: [Entity])?) {
		
		var sectionIndex = 0
		if let sectionName = sectionName {
			sectionIndex = self.indexOfSection(withSectionName: sectionName)!
		}
		
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

	mutating func append(contentsOf sections: [SectionInfo<Entity>]) {
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
		
		if sectionName == nil {
			if let row = self.sections[0].index(of: entity) {
				return IndexPath(row: row, section: 0)
			}
		}
		else {
			if let sectionIndex = self.indexOfSection(withSectionName: sectionName!), let row = self.sections[sectionIndex].index(of: entity) {
				return IndexPath(row: row, section: sectionIndex)
			}
		}
		
		return nil
	}
	
	func indexPath(of entity: Entity, atSection sectionIndex: Int) -> IndexPath? {
		
		if let row = self.sections[sectionIndex].index(of: entity) {
			return IndexPath(row: row, section: sectionIndex)
		}

		return nil
	}

	
	func index(of section: SectionInfo<Entity>) -> Int? {
		return self.sections.index(of: section)
	}
	
	func indexOfSection(withSectionName sectionName: String) -> Int? {
		let filtered = self.sections.filter { $0.name == sectionName }
		if let section = filtered.first {
			return self.index(of: section)
		}
		return nil
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
	
	mutating func newSection(with entities: [Entity], name: String) -> SectionInfo<Entity> {
		let section = SectionInfo(entities: entities, name: name, indexTitle: nil)
		return section
	}
	
	mutating func sortEntities(atSection sectionIndex: Int, with sort: ((Entity, Entity) -> Bool)) -> (oldIndexPaths: [IndexPath], newIndexPaths: [IndexPath]) {
		let result = self[sectionIndex]?.sort(by: sort)
		let oldIndexPaths = result?.oldIndexes.map { IndexPath(row: $0, section: sectionIndex) } ?? []
		let newIndexPaths = result?.newIndexes.map { IndexPath(row: $0, section: sectionIndex) } ?? []
		return (oldIndexPaths: oldIndexPaths, newIndexPaths: newIndexPaths)
	}
	
	mutating func sortSections(with sort: ((SectionInfo<Entity>, SectionInfo<Entity>) -> Bool)) -> (oldIndexes: [Int], newIndexes: [Int]) {
		let oldSections = self.sections
		self.sections.sort(by: sort)
		let oldIndexes = Array(0..<oldSections.count)
		let newIndexes = oldSections.map { self.sections.index(of: $0) }
		return (oldIndexes: oldIndexes, newIndexes:newIndexes as! [Int])
	}
	
	func filteredEntities(atSection sectionIndex: Int, with filter: ((Entity) -> Bool)) -> [Entity] {
		return self[sectionIndex]?.filter(by: filter) ?? []
	}
	
}
