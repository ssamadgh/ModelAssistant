//
//  ModelSectionInfo.swift
//  MyModelLibrary
//
//  Created by Seyed Samad Gholamzadeh on 8/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation


public protocol ModelSectionInfo {
	
	var numberOfEntities: Int { get }
	
	var name: String  { get }
	
	var indexTitle: String?  { get }
	
}

protocol GModelSectionInfo: ModelSectionInfo {
	
	associatedtype Entity: EntityProtocol, Hashable
	
	var entities: [Entity]  { get set}
	
}

public struct SectionInfo<Entity: EntityProtocol & Hashable>: GModelSectionInfo, Equatable, Comparable {
	
	
	static public  func ==(lhs: SectionInfo<Entity>, rhs: SectionInfo<Entity>) -> Bool {
		return lhs.name == rhs.name
	}
	
	static public func <(lhs: SectionInfo<Entity>, rhs: SectionInfo<Entity>) -> Bool {
		return lhs.name < rhs.name
	}
	
	public internal (set) var entities: [Entity] = []
	
	public internal (set) var name: String
	
	public internal (set) var indexTitle: String?
	

	public var numberOfEntities: Int {
		guard !self.isEmpty else { return 0 }
		return entities.count
	}
	
	public var isEmpty: Bool {
		return entities.isEmpty
	}

	subscript(index: Int) -> Entity? {
		
		get {
			if index < self.numberOfEntities {
				return entities[index]
			}
			else {
				return nil
			}
		}
		
		set {
			if index < self.numberOfEntities {
				if newValue != nil {
					self.entities[index] = newValue!
				}
			}
		}
	}
	
	mutating func append(_ newEntity: Entity) -> (updated: (indexes: [Int], entities: [Entity])?, inserted:  (indexes: [Int], entities: [Entity])?) {
		return self.append(contentsOf: [newEntity])
	}
	
	mutating func append(contentsOf newEntities: [Entity]) -> (updated: (indexes: [Int], entities: [Entity])?, inserted:  (indexes: [Int], entities: [Entity])?) {
		
		var updatedEntities: [Entity] = []
		var updatedIndexes: [Int] = []
		var insertedEntities: [Entity] = []
		var insertedIndexes: [Int] = []
		
		for entity in newEntities {
			if self.entities.contains(entity) {
				let updatedIndex = self.entities.index(of: entity)!
				
				updatedEntities.append(entity)
				updatedIndexes.append(updatedIndex)
				self.entities[updatedIndex].update(with: entity)
			}
			else {
				insertedEntities.append(entity)
			}
		}
		
		let lowerBound = self.entities.count
		let upperBound = lowerBound + (insertedEntities.count - 1)
		insertedIndexes = !insertedEntities.isEmpty ? Array(lowerBound ... upperBound) : []
		self.entities.append(contentsOf: insertedEntities)
		
		let updated = !updatedIndexes.isEmpty ? (indexes: updatedIndexes, entities: updatedEntities) : nil
		let inserted = !insertedIndexes.isEmpty ? (indexes: insertedIndexes, entities: insertedEntities) : nil
		return (updated: updated, inserted:  inserted)
	}
	
	mutating func insert(_ entity: Entity, at index: Int) {
		if index <= self.numberOfEntities {
			self.entities.insert(entity, at: index)
		}
		else {
			fatalError("Index out of range")
		}

	}
	
	func entity(at index: Int) -> Entity {
		if index < self.numberOfEntities {
			return entities[index]
		}
		else {
			fatalError("Index out of range")
		}
	}
	
	mutating func remove(at index: Int) -> Entity {
		return self.entities.remove(at: index)
	}
	
	mutating func update(_ entity: Entity, at index: Int) {
		self.entities[index] = entity
	}
	
	func index(of entity: Entity) -> Int? {
		return self.entities.index(of: entity)
	}
	
	mutating func sort(by sort: (Entity, Entity) -> Bool) -> (oldIndexes: [Int], newIndexes: [Int]) {
		let oldEntities = self.entities
		self.entities.sort(by: sort)
		let oldIndexes = Array(0..<oldEntities.count)
		let newIndexes = oldEntities.map { self.entities.index(of: $0) }
		return (oldIndexes: oldIndexes, newIndexes:newIndexes as! [Int])
	}
	
	func filter(by filter: ((Entity) -> Bool)) -> [Entity] {
		return self.entities.filter(filter)
	}

}

