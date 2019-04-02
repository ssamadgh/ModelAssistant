/**
MASectionInfo.swift
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

///A protocol that defines the interface for section objects vended by a fetched results controller.
public protocol MASectionInfo {

	associatedtype Entity: MAEntity, Hashable

	///The number of entities (rows) in the section.
	var numberOfEntities: Int { get }

	///The name of the section.
	var name: String  { get }

	/**
	The index title of the section.

	This is used when displaying the index.
	*/
	var indexTitle: String?  { get }

	///The array of entities in the section.
	var entities: [Entity]  { get}

}

public extension MASectionInfo {

	static func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.name == rhs.name
	}

	static func <(lhs: Self, rhs: Self) -> Bool {
		return lhs.name < rhs.name
	}

	#if swift(>=4.2)
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
	#else
	var hashValue: Int {
	return name.hashValue
	}
	#endif

}

public struct SectionInfo<Entity: MAEntity & Hashable>: MASectionInfo, Hashable, Comparable {

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

	mutating func append<S>(contentsOf newEntities: S) -> (updated: (indexes: [Int], entities: [Entity])?, inserted:  (indexes: [Int], entities: [Entity])?) where S.Element == Entity, S: Sequence {

		var newEntities = Array(newEntities)
		let startIndex = newEntities.stablePartition(isSuffixElement: { !self.entities.contains($0) })

		let updatedEntities: [Entity] = Array(newEntities[0..<startIndex])
		let updatedIndexes: [Int] = updatedEntities.compactMap { self.entities.firstIndex(of: $0) }
		let insertedEntities: [Entity] = Array(newEntities[startIndex...])
		let lowerBound = self.entities.count
		let upperBound = lowerBound + (insertedEntities.count - 1)
		let insertedIndexes: [Int] = !insertedEntities.isEmpty ? Array(lowerBound ... upperBound) : []
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

	func firstIndex(of entity: Entity) -> Int? {
		return self.entities.firstIndex(of: entity)
	}

	mutating func sort(by sort: (Entity, Entity) -> Bool) -> (oldIndexes: [Int], newIndexes: [Int]) {
		let oldEntities = self.entities
		self.entities.sort(by: sort)
		let oldIndexes = Array(0..<oldEntities.count)
		let newIndexes = oldEntities.map { self.entities.firstIndex(of: $0) }
		return (oldIndexes: oldIndexes, newIndexes:newIndexes as! [Int])
	}

	func filter(by filter: ((Entity) -> Bool)) -> [Entity] {
		return self.entities.filter(filter)
	}

	func contains(_ entity: Entity) -> Bool {
		return self.entities.contains(entity)
	}



}

extension SectionInfo where Entity: MAFaultable {

	mutating func fault(in range: Range<Int>) {
		range.forEach{ self.entities[$0].fault() }
	}

	mutating func fire(in range: Range<Int>) {
		range.forEach{ self.entities[$0].fire() }
	}

}

