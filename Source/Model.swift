//
//  Model.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 3/3/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

/// Constants that specify the possible types of changes that are reported.
public enum ModelChangeType {
	
	/// Specifies that an object was inserted.
	case insert
	
	/// Specifies that an object was deleted.
	case delete
	
	/// Specifies that an object was moved.
	case move
	
	/// Specifies that an object was changed.
	case update
	
}



public protocol ModelDelegate: class {
	
	func modelWillChangeContent(for type: ModelChangeType)
	
	func modelDidChangeContent(for type: ModelChangeType)
	
	func model(didChange entities: [EntityProtocol], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?)
	
	func model(didChange sectionInfo: ModelSectionInfo, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?)
}


public extension ModelDelegate {
	
	func modelWillChangeContent(for type: ModelChangeType) {
		
	}
	
	func modelDidChangeContent(for type: ModelChangeType) {
		
	}
	
	func model(didChange entities: [EntityProtocol], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
		
	}
	
	func model(didChange sectionInfo: ModelSectionInfo, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) {
		
	}
	
}

//MARK: - Model class

public class Model<Entity: EntityProtocol & Hashable> {
	
	private let dispatchQueue = DispatchQueue(label: "com.model.ConcirrentGCD.DispatchQueue", attributes: DispatchQueue.Attributes.concurrent)
	
	
	public var fetchBatchSize: Int
	
	public subscript(indexPath: IndexPath) -> Entity {
		get {
			return self.entity(at: indexPath)
		}
	}
	
	public subscript(index: Int) -> SectionInfo<Entity> {
		get {
			return self.section(at: index)
		}
	}
	
	public var sectionKey: String? {
		didSet {
			self.hasSection = self.sectionKey != nil
		}
	}
	
	public var sort: ((Entity, Entity) -> Bool)?
	
	public var filter: ((Entity) -> Bool)?
	
	private var hasSection: Bool
	
	private var sectionsManager: SectionsManager<Entity>!
	
	public weak var delegate: ModelDelegate?
	
	//	var entities: [Entity]
	
	private var entitiesUniqueValue: Set<Int>
	
	public init(sectionName: String? = nil) {
		entitiesUniqueValue = []
		fetchBatchSize = 10
		self.sectionKey = sectionName
		self.hasSection = sectionName != nil
		self.sectionsManager = SectionsManager()
	}
	
	public var isEmpty: Bool {
		return sectionsManager.isEmpty
	}
	
	public var numberOfSections: Int {
		var numberOfSections: Int!
		
		self.dispatchQueue.sync {
			numberOfSections = sectionsManager.numberOfSections
		}
		
		return numberOfSections
	}
	
	public var numberOfFetchedEntities: Int {
		var numberOfFetchedEntities: Int!
		
		self.dispatchQueue.sync {
			numberOfFetchedEntities = self.entitiesUniqueValue.count
		}
		
		return numberOfFetchedEntities
	}
	
	public var numberOfWholeEntities: Int {
		var numberOfWholeEntities: Int = 0
		
		self.dispatchQueue.sync {
			for i in 0...self.numberOfSections-1 {
				numberOfWholeEntities += self.numberOfEntites(at: i)
			}
		}
		
		return numberOfWholeEntities
	}

	
	public func numberOfEntites(at sectionIndex: Int) -> Int {
		var numberOfEntites: Int!
		
		self.dispatchQueue.sync {
			numberOfEntites = self.sectionsManager.numberOfEntites(at: sectionIndex)
		}
		
		return numberOfEntites
	}
	
	private var entitiesIdIsEmpty: Bool {
		var isEmpty = false
		
		self.dispatchQueue.sync {
			isEmpty = self.entitiesUniqueValue.isEmpty
		}
		
		return isEmpty
	}
	
	public var lastIndex: Int {
		guard fetchBatchSize != 0 else { return 0}
		let subtract = numberOfFetchedEntities/fetchBatchSize
		return numberOfFetchedEntities%fetchBatchSize == 0 ? subtract - 1 : subtract
	}
	
	public var nextIndex: Int {
		guard fetchBatchSize != 0 else { return 0}
		guard !entitiesIdIsEmpty else { return 0 }
		return numberOfFetchedEntities%fetchBatchSize == 0 ? lastIndex + 1 : lastIndex
	}
	
	private var numberOfLastFetchedEntities: Int {
		guard fetchBatchSize != 0 else { return numberOfFetchedEntities }
		let numberOfEntities = self.numberOfFetchedEntities
		if numberOfEntities == 0 { return 0 }
		let lastCompleteIndex = Int(floor(Double(numberOfEntities)/Double(self.fetchBatchSize)))
		let diff = numberOfEntities - lastCompleteIndex*self.fetchBatchSize
		return diff == 0 ? self.fetchBatchSize : diff
	}
	
	public func index(of section: SectionInfo<Entity>) -> Int? {
		var index: Int?
		
		self.dispatchQueue.sync {
			index = self.sectionsManager.index(of: section)
		}
		
		return index
	}
	
	func indexOfSection(withSectionName sectionName: String) -> Int? {
		var index: Int?
		
		self.dispatchQueue.sync {
			index = self.sectionsManager.indexOfSection(withSectionName: sectionName)
		}
		
		return index
	}
	
	private func indexPath(of entity: Entity, synchronous: Bool) -> IndexPath? {
		let sectionName = self.hasSection ? entity[self.sectionKey!] : nil
		var indexPath: IndexPath?

		func getIndexPath() {
			indexPath = self.sectionsManager.indexPath(of: entity, withSectionName: sectionName)
			
			if self.hasSection, indexPath == nil {
				for i in 0...(self.sectionsManager.numberOfSections-1) {
					let sectionName = self.sectionsManager[i].name
					if let path = self.sectionsManager.indexPath(of: entity, withSectionName: sectionName) {
						indexPath = path
						break
					}
				}
			}
		}
		
		if synchronous {
			self.dispatchQueue.sync {
				getIndexPath()
			}
		}
		else {
			getIndexPath()
		}
		
		return indexPath
	}
	
	public func indexPath(of entity: Entity) -> IndexPath? {
		return self.indexPath(of: entity, synchronous: true)
	}
	
	private func privateIndexPath(of entity: Entity) -> IndexPath? {
		return indexPath(of: entity, synchronous: false)
	}

	
	public func indexPathOfEntity(withUniqueValue uniqueValue: Int) -> IndexPath? {
		var indexPath: IndexPath?
		
		self.dispatchQueue.sync {
			if self.entitiesUniqueValue.contains(uniqueValue) {
				if let entity = self.filteredEntities(with: { $0.uniqueValue == uniqueValue }).first {
					indexPath = self.indexPath(of: entity)
				}
			}
		}
		
		return indexPath
	}
	
	
	//MARK: - Insert methods

	public func insertAtFirst(_ newEntity: Entity, beginUpdate: Bool = true, endUpdate: Bool = true, finished:(() -> ())? = nil) {
		self.insert(newEntity, at: IndexPath(row: 0, section: 0), beginUpdate: beginUpdate, endUpdate: endUpdate, finished: finished)
	}
	
	public func insert(_ newEntity: Entity, at indexPath: IndexPath, beginUpdate: Bool = true, endUpdate: Bool = true, finished:(() -> ())? = nil) {
		let isMainThread = Thread.isMainThread
		
		self.dispatchQueue.async(flags: .barrier) {
			
			self.entitiesUniqueValue.insert(newEntity.uniqueValue)
			
			if beginUpdate {
				self.modelWillChangeContent(for: .delete)
			}
			
			let sectionIndex = indexPath.section
			let diff = self.sectionsManager.numberOfSections - sectionIndex
			
			if diff >= 0 {
				if diff == 0 {
					let sectionName = self.hasSection ? newEntity[self.sectionKey!]! : ""
					let section = self.sectionsManager.newSection(with: [newEntity], name: sectionName)
					self.sectionsManager.insert(section, at: sectionIndex)
					
					self.model(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: sectionIndex)
				}
				else {
					self.sectionsManager.insert(newEntity, at: indexPath)
					
					self.model(didChange: [newEntity], at: nil, for: .insert, newIndexPaths: [indexPath])

				}
			}
			else {
				fatalError("section Index out of range")
			}
			
			if endUpdate {
				self.modelDidChangeContent(for: .insert)
			}
			
			self.checkIsMainThread(isMainThread, completion: finished)
			
		}
	}
	
	public func insertAtLast(_ newEntity: Entity, beginUpdate: Bool = true, endUpdate: Bool = true, finished:(() -> ())? = nil) {
		let section = self.numberOfSections - 1
		let row = self.numberOfEntites(at: section)
		self.insert(newEntity, at: IndexPath(row: row, section: section), beginUpdate: beginUpdate, endUpdate: endUpdate, finished: finished)
	}
	
	public func fetch(_ entities: [Entity], finished:(() -> ())?) {
		self.insert(entities, beginUpdate: false, endUpdate: false, callModelDelegateMethods: false, finished: finished)
	}
	
	public func insert(_ newEntities: [Entity], beginUpdate: Bool = true, endUpdate: Bool = true, finished:(() -> ())? = nil) {
		self.insert(newEntities, beginUpdate: beginUpdate, endUpdate: endUpdate, callModelDelegateMethods: true, finished: finished)
	}
	
	
	private func insert(_ newEntities: [Entity], beginUpdate: Bool, endUpdate: Bool, callModelDelegateMethods: Bool, finished:(() -> ())?) {
		
		let isMainThread = Thread.isMainThread

		self.dispatchQueue.async(flags: .barrier) {
			
			var newEntitiesUniqueValue = Set(newEntities.map { $0.uniqueValue })
			
			newEntitiesUniqueValue.subtract(self.entitiesUniqueValue)
			
			self.entitiesUniqueValue.formUnion(newEntitiesUniqueValue)
			
			var newEntities = newEntities
			
			if self.filter != nil {
				newEntities = newEntities.filter(self.filter!)
			}
			
			
			if beginUpdate, callModelDelegateMethods {
				self.modelWillChangeContent(for: .insert)
			}
			
			
			func insert(_ newEntities: [Entity], toSectionWithName sectionName: String?, sectionIndex: Int) {
				
				let result = self.sectionsManager.insert(newEntities, toSectionWithName: sectionName)
				if let updated = result.updated, callModelDelegateMethods {
					self.model(didChange: updated.entities, at: updated.indexPaths, for: .update, newIndexPaths: nil)
				}
				
				if let inserted = result.inserted {
					
					
					if self.sort == nil {
						if callModelDelegateMethods {
							self.model(didChange: inserted.entities, at: nil, for: .insert, newIndexPaths: inserted.indexPaths)
						}
					}
					else {
						let result = self.sectionsManager.sortEntities(atSection: sectionIndex, with: self.sort!)
						if callModelDelegateMethods {
							var newIndexPaths: [IndexPath] = []
							
							for entity in inserted.entities {
								newIndexPaths.append(self.sectionsManager.indexPath(of: entity, atSection: sectionIndex)!)
							}
							self.model(didChange: inserted.entities, at: nil, for: .insert, newIndexPaths: newIndexPaths)
							
						}
					}
					
					
					
				}
				
			}
			
			func insert(_ newEntities: [Entity], toNewSectionWithName sectionName: String?) {
				let section = self.sectionsManager.newSection(with: newEntities, name: sectionName ?? "")
				self.sectionsManager.append(section)
				
				let sectionIndex = self.sectionsManager.index(of: section)!
				
				if callModelDelegateMethods {
					self.model(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: sectionIndex)
				}
				
				if self.sort != nil {
					let result = self.sectionsManager.sortEntities(atSection: sectionIndex, with: self.sort!)
					if callModelDelegateMethods {
						self.model(didChange: self.sectionsManager.entities(atSection: sectionIndex), at: result.oldIndexPaths, for: .move, newIndexPaths: result.newIndexPaths)
						
					}
				}
				
			}
			
			if !self.hasSection {
				
				if self.sectionsManager.isEmpty {
					
					insert(newEntities, toNewSectionWithName: nil)
					
				}
				else {
					let sectionIndex: Int = 0
					insert(newEntities, toSectionWithName: nil, sectionIndex: sectionIndex)
					
				}
				
			}
			else {
				
				while !newEntities.isEmpty {
					
					let firstEntity = newEntities.first!
					let sectionName = firstEntity[self.sectionKey!]!
					let filtered = newEntities.filter { $0[self.sectionKey!] == sectionName }
					
					if self.sectionsManager.containsSection(with: sectionName) {
						let sectionIndex = self.sectionsManager.indexOfSection(withSectionName: sectionName)!
						insert(filtered, toSectionWithName: sectionName, sectionIndex: sectionIndex)
						
					}
					else {
						insert(filtered, toNewSectionWithName: sectionName)
					}
					
					
					for entity in filtered {
						newEntities.remove(at: newEntities.index(of: entity)!)
					}
					
				}
				
			}
			
			
			if endUpdate, callModelDelegateMethods {
				self.modelDidChangeContent(for: .insert)
			}
			
			self.checkIsMainThread(isMainThread, completion: finished)
			
		}
		
	}
	
	//MARK: - Move methods

	public func moveEntity(at indexPath: IndexPath, to newIndexPath: IndexPath, isUserDriven: Bool, beginUpdate: Bool = true, endUpdate: Bool = true, finished:(() -> ())? = nil) {
		
		let isMainThread = Thread.isMainThread

		dispatchQueue.async(flags: .barrier) {

			if beginUpdate, !isUserDriven {
				self.modelWillChangeContent(for: .insert)
			}

		let entity = self.sectionsManager.remove(at: indexPath)
		self.sectionsManager.insert(entity, at: newIndexPath)
			
			if !isUserDriven {
				self.model(didChange: [entity], at: [indexPath], for: .move, newIndexPaths: [newIndexPath])
			}
			
			if endUpdate, !isUserDriven {
				self.modelDidChangeContent(for: .insert)
			}
			
			self.checkIsMainThread(isMainThread, completion: finished)

		}
	}
	
	//MARK: - Update methods

	public func update(at indexPath: IndexPath, mutate: @escaping (inout Entity) -> Void, finished: (() -> ())? = nil) {
		
		let isMainThread = Thread.isMainThread

		dispatchQueue.async(flags: .barrier) {
			
			var entity = self.sectionsManager[indexPath]
			mutate(&entity)
			self.sectionsManager[indexPath] = entity
			
			self.model(didChange: [entity], at: [indexPath], for: .update, newIndexPaths: nil)
			
			self.checkIsMainThread(isMainThread) {
				finished?()
			}

		}
	}
	
	//MARK: - Remove methods
	
	public func remove(at indexPath: IndexPath, removeEmptySection: Bool, beginUpdate: Bool = true, endUpdate: Bool = true, finished: ((Entity) -> ())? = nil) {
		
		let isMainThread = Thread.isMainThread

		self.dispatchQueue.async(flags: .barrier) {
			
			if beginUpdate {
				self.modelWillChangeContent(for: .delete)
			}
			
			let sectionIndex = indexPath.section
			
			let entity = self.sectionsManager.remove(at: indexPath)
			
			if let index = self.entitiesUniqueValue.index(of: entity.uniqueValue) {
				self.entitiesUniqueValue.remove(at: index)
			}
			
			if removeEmptySection, self.sectionsManager[sectionIndex].isEmpty {
				let section = self.sectionsManager.remove(at: sectionIndex)
				self.model(didChange: section, atSectionIndex: sectionIndex, for: .delete, newSectionIndex: nil)
			}
			else {
				self.model(didChange: [entity], at: [indexPath], for: .delete, newIndexPaths: nil)
			}
			
			
			if endUpdate {
				self.modelDidChangeContent(for: .delete)
			}
			
			self.checkIsMainThread(isMainThread) {
				finished?(entity)
			}
		}
	}
	
	public func remove(_ entity: Entity, removeEmptySection: Bool, beginUpdate: Bool = true, endUpdate: Bool = true, finished: ((Entity) -> ())? = nil) {
		
		if let indexPath = self.indexPath(of: entity) {
			self.remove(at: indexPath, removeEmptySection: removeEmptySection, beginUpdate: beginUpdate, endUpdate: endUpdate, finished: finished)
		}
		else {
			print("Index out of range")
		}
	}

	public func removeAllEntities(atSection sectionIndex: Int, beginUpdate: Bool = true, endUpdate: Bool = true, finished: (([Entity]) -> ())? = nil) {
		
		let isMainThread = Thread.isMainThread

		self.dispatchQueue.async(flags: .barrier) {
			
			if beginUpdate {
				self.modelWillChangeContent(for: .delete)
			}
			
			let removedEntities = self.sectionsManager[sectionIndex].entities
			let removedIndexPaths = IndexPath.indexPaths(in: 0...removedEntities.count-1, atSection: sectionIndex)
			
			self.sectionsManager.remvoeAllEntities(atSection: sectionIndex)
			
			self.model(didChange: removedEntities, at: removedIndexPaths, for: .delete, newIndexPaths: nil)
			
			if endUpdate {
				self.modelDidChangeContent(for: .delete)
			}
			
			self.checkIsMainThread(isMainThread) {
				finished?(removedEntities)
			}

		}
		
	}
	
	public func removeSection(at sectionIndex: Int, beginUpdate: Bool = true, endUpdate: Bool = true, finished: ((SectionInfo<Entity>) -> ())? = nil) {
		
		let isMainThread = Thread.isMainThread
		
		self.dispatchQueue.async(flags: .barrier) {
			
			if beginUpdate {
				self.modelWillChangeContent(for: .delete)
			}
			
			let section = self.sectionsManager.remove(at: sectionIndex)
			self.model(didChange: section, atSectionIndex: sectionIndex, for: .delete, newSectionIndex: nil)
			
			if endUpdate {
				self.modelDidChangeContent(for: .delete)
			}
			
			self.checkIsMainThread(isMainThread) {
				finished?(section)
			}

		}
	}
	
	public func removeAll(finished: (() -> ())?) {
		
		let isMainThread = Thread.isMainThread

		dispatchQueue.async(flags: .barrier) {
			
			self.sectionsManager.removeAll()
			self.checkIsMainThread(isMainThread, completion: finished)
		}
	}

	//MARK: - Get Section
	
	public func section(at sectionIndex: Int) -> SectionInfo<Entity> {
		
		var section: SectionInfo<Entity>!
		
		self.dispatchQueue.sync {
			section = self.sectionsManager[sectionIndex]
		}
		
		return section
	}
	
	//MARK: - Get Entity

	public func entity(at indexPath: IndexPath) -> Entity {
		
		var entity: Entity!
		
		self.dispatchQueue.sync {
			entity = self.sectionsManager[indexPath]
		}
		
		return entity
	}
	
	//MARK: - Sort methods

	public func sortEntities(atSection sectionIndex: Int, with sort: @escaping ((Entity, Entity) -> Bool), beginUpdate: Bool = true, endUpdate: Bool = true, finished: ((_ newIndexPaths: [IndexPath]) -> Void)?) {
		
		let isMainThread = Thread.isMainThread

		self.dispatchQueue.async(flags: .barrier) {
			if beginUpdate {
				self.modelWillChangeContent(for: .move)
			}
			
			let entities = self.sectionsManager.entities(atSection: sectionIndex)
			let result = self.sectionsManager.sortEntities(atSection: sectionIndex, with: sort)
			self.model(didChange: entities, at: result.oldIndexPaths, for: .move, newIndexPaths: result.newIndexPaths)
			
			if endUpdate {
				self.modelDidChangeContent(for: .move)
			}
			
			self.checkIsMainThread(isMainThread) {
				finished?(result.newIndexPaths)
			}

		}
		
	}
	
	public func reorder(finished: (() -> Void)?) {
		guard self.sort != nil else { return }
		
		let firstIndex = 0
		let lastIndex = self.numberOfSections-1
		
		let isMainThread = Thread.isMainThread
		
		self.dispatchQueue.async(flags: .barrier) {
			if lastIndex == 0 {
				self.sortEntities(atSection: firstIndex, with: self.sort!, beginUpdate: true, endUpdate: true, finished: nil)
			}
			else {
				for index in firstIndex...lastIndex {
					
					if index == firstIndex {
						self.sortEntities(atSection: index, with: self.sort!, beginUpdate: true, endUpdate: false, finished: nil)
					}
					else if index == lastIndex {
						self.sortEntities(atSection: index, with: self.sort!, beginUpdate: false, endUpdate: true, finished: nil)
					}
					else {
						self.sortEntities(atSection: index, with: self.sort!, beginUpdate: false, endUpdate: false, finished: nil)
					}
					
				}
			}
			
			self.checkIsMainThread(isMainThread, completion: finished)
			
		}
	}
	
	public func sortSections(with sort: @escaping ((SectionInfo<Entity>, SectionInfo<Entity>) -> Bool), beginUpdate: Bool = true, endUpdate: Bool = true, finished: ((_ newIndexPaths: [Int]) -> Void)?) {
		
		let isMainThread = Thread.isMainThread

		self.dispatchQueue.async(flags: .barrier) {
			if beginUpdate {
				self.modelWillChangeContent(for: .move)
			}
			
			let oldSections = self.sectionsManager.sections
			
			let result = self.sectionsManager.sortSections(with: sort)
			
			let oldIndexes = result.oldIndexes
			let newIndexes = result.newIndexes
			
			for i in 0...(oldSections.count-1) {
				let section = oldSections[i]
				let oldIndex = oldIndexes[i]
				let newIndex = newIndexes[i]
				self.model(didChange: section, atSectionIndex: oldIndex, for: .move, newSectionIndex: newIndex)
			}
			
			if endUpdate {
				self.modelDidChangeContent(for: .move)
			}
			
			self.checkIsMainThread(isMainThread) {
				finished?(result.newIndexes)
			}

		}
		
	}
	
	//MARK: - filter methods
	
	public func filteredEntities(atSection sectionIndex: Int, with filter: ((Entity) -> Bool)) -> [Entity] {
		var entities: [Entity]!
		self.dispatchQueue.sync {
			entities = self.sectionsManager.filteredEntities(atSection: sectionIndex, with: filter)
		}
		
		return entities ?? []
	}
	
	public func filteredEntities(with filter: ((Entity) -> Bool)) -> [Entity] {
		var entities: [Entity] = []
		
		self.dispatchQueue.sync {
			for i in 0...(self.numberOfSections-1) {
				let filtered = self.sectionsManager.filteredEntities(atSection: i, with: filter)
				entities.append(contentsOf: filtered)
			}
		}
		
		return entities
	}
	
	public func allEntitiesForExport(sortedBy sort: ((Entity, Entity) -> Bool)?) -> [Entity] {
		var entities: [Entity] = []
		
		self.dispatchQueue.sync {
			for i in 0...(self.numberOfSections-1) {
				let sectionEntities = self.sectionsManager.entities(atSection: i)
				entities.append(contentsOf: sectionEntities)
			}
		}
		
		if sort != nil {
			entities.sort(by: sort!)
		}
		
		return entities
	}
	
	//MARK: - Delegate methods
	
	private func modelWillChangeContent(for type: ModelChangeType) {
		DispatchQueue.main.async {
			self.delegate?.modelWillChangeContent(for: type)
		}
	}
	
	private func modelDidChangeContent(for type: ModelChangeType) {
		DispatchQueue.main.async {
			self.delegate?.modelDidChangeContent(for: type)
		}
		
	}
	
	private func model(didChange entities: [EntityProtocol], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
		DispatchQueue.main.async {
			self.delegate?.model(didChange: entities, at: indexPaths, for: type, newIndexPaths: newIndexPaths)
		}
	}
	
	private func model(didChange sectionInfo: ModelSectionInfo, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) {
		DispatchQueue.main.async {
			self.delegate?.model(didChange: sectionInfo, atSectionIndex: sectionIndex, for: type, newSectionIndex: newSectionIndex)
		}
	}
	
	private func checkIsMainThread(_ isMainThread: Bool, completion: (() -> Void)?) {
		guard completion != nil else {
			return
		}
		if isMainThread {
			DispatchQueue.main.async(execute: completion!)
		}
		else {
			DispatchQueue.global().async(execute: completion!)
		}
	}
	

}


