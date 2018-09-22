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

//MARK: - Model Delegate

public protocol ModelDelegate: class {
	
	func modelWillChangeContent()
	
	func modelDidChangeContent()
	
	func model<Entity: EntityProtocol & Hashable>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?)
	
	func model<Entity: EntityProtocol & Hashable>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?)
	
	func model(sectionIndexTitleForSectionName sectionName: String) -> String?
}


public extension ModelDelegate {
	
	func modelWillChangeContent() {
		
	}
	
	func modelDidChangeContent() {
		
	}
	
	func model<Entity: EntityProtocol & Hashable>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
		
	}
	
	func model<Entity: EntityProtocol & Hashable>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) {
		
	}
	
	func model(sectionIndexTitleForSectionName sectionName: String) -> String? {
		return String(Array(sectionName)[0]).uppercased()
	}
	
}


//MARK: - Model class

public final class Model<Entity: EntityProtocol & Hashable>: NSObject, ModelProtocol {
	
	private let dispatchQueue = DispatchQueue(label: "com.model.ConcirrentGCD.DispatchQueue", attributes: DispatchQueue.Attributes.concurrent)
	
	private let operationQueue = AOperationQueue()
	
	public var fetchBatchSize: Int
	
	public subscript(indexPath: IndexPath) -> Entity? {
		get {
			return self.entity(at: indexPath)
		}
	}
	
	public subscript(index: Int) -> SectionInfo<Entity>? {
		get {
			return self.section(at: index)
		}
	}
	
	public var sectionIndexTitles: [String] {
		var titles: [String]!
		
		self.dispatchQueue.sync {
			titles = self.sectionsManager.sectionIndexTitles
		}
		
		return titles
	}
	
	public private (set) var sectionKey: String?
	
	public var sortEntities: ((Entity, Entity) -> Bool)?
	
	public var sortSections: ((SectionInfo<Entity>, SectionInfo<Entity>) -> Bool)?
	
	public var filter: ((Entity) -> Bool)?
	
	private var hasSection: Bool
	
	private var sectionsManager: SectionsManager<Entity>!
	
	public weak var delegate: ModelDelegate?
	
	//	var entities: [Entity]
	
	private var entitiesUniqueValue: Set<Int>
	
	public init(sectionKey: String?) {
		operationQueue.maxConcurrentOperationCount = 1
		entitiesUniqueValue = []
		fetchBatchSize = 20
		self.sectionKey = sectionKey
		self.hasSection = sectionKey != nil
		self.sectionsManager = SectionsManager()
		super.init()
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
	
	var numberOfFetchedEntities: Int {
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
					let sectionName = self.sectionsManager[i]?.name
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
	
	//	public func insertAtFirst(_ newEntity: Entity, completion:(() -> ())?) {
	//		self.insert(newEntity, at: IndexPath(row: 0, section: 0), completion: completion)
	//	}
	
	public func insert(_ newEntity: Entity, at indexPath: IndexPath, completion:(() -> ())?) {
		
		let isMainThread = Thread.isMainThread
		
		self.addModelOperation(with: BlockOperation(block: { (finished) in
			
			self.dispatchQueue.async(flags: .barrier) {
				
				let sectionIndex = indexPath.section
				let diff = self.sectionsManager.numberOfSections - sectionIndex
				
				if diff >= 0 {
					if diff == 0 {
						let sectionName = self.hasSection ? newEntity[self.sectionKey!]! : ""
						let indexTitle = self.sectionIndexTitle(forSectionName: sectionName)
						let section = self.sectionsManager.newSection(with: [newEntity], name: sectionName, indexTitle: indexTitle)
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
				
				finished()
				
			}
		})) {
			self.checkIsMainThread(isMainThread, completion: completion)
		}
		
	}
	
	//	public func insertAtLast(_ newEntity: Entity, completion:(() -> ())?) {
	//		let section = self.numberOfSections - 1
	//		let row = self.numberOfEntites(at: section)
	//		self.insert(newEntity, at: IndexPath(row: row, section: section), completion: completion)
	//	}
	
	public func fetch(_ entities: [Entity], completion:(() -> ())?) {
		self.insert(entities, callModelDelegateMethods: false, completion: completion)
	}
	
	public func insert(_ newEntities: [Entity], completion:(() -> ())?) {
		self.insert(newEntities, callModelDelegateMethods: true, completion: completion)
	}
	
	
	
	private func insert(_ newEntities: [Entity], callModelDelegateMethods: Bool, completion:(() -> ())?) {
		
		let isMainThread = Thread.isMainThread
		
		func inserMethod() {
			
			var newEntitiesUniqueValue = Set(newEntities.map { $0.uniqueValue })
			
			newEntitiesUniqueValue.subtract(self.entitiesUniqueValue)
			
			self.entitiesUniqueValue.formUnion(newEntitiesUniqueValue)
			
			var newEntities = newEntities
			
			if self.filter != nil {
				newEntities = newEntities.filter(self.filter!)
			}
			
			func insert(_ newEntities: [Entity], toSectionWithName sectionName: String?, sectionIndex: Int) {
				
				let result = self.sectionsManager.insert(newEntities, toSectionWithName: sectionName)
				if let updated = result.updated, callModelDelegateMethods {
					
					self.model(didChange: updated.entities, at: updated.indexPaths, for: .update, newIndexPaths: nil)
				}
				
				if let inserted = result.inserted {
					
					
					if self.sortEntities == nil {
						if callModelDelegateMethods {
							self.model(didChange: inserted.entities, at: nil, for: .insert, newIndexPaths: inserted.indexPaths)
						}
					}
					else {
						
						_ = self.sectionsManager.sortEntities(atSection: sectionIndex, by: self.sortEntities!)
						
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
				var newEntities = newEntities
				
				if let sortEntities = self.sortEntities {
					newEntities.sort(by: sortEntities)
				}
				let sectionName = sectionName ?? ""
				let indexTitle = self.sectionIndexTitle(forSectionName: sectionName)
				let section = self.sectionsManager.newSection(with: newEntities, name: sectionName, indexTitle: indexTitle)
				self.sectionsManager.append(section)
				
				let sectionIndex = self.sectionsManager.index(of: section)!
				
				if callModelDelegateMethods {
					self.model(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: sectionIndex)
					
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
				
				var newSectionNames = Set(newEntities.compactMap {  $0[self.sectionKey!] })
				
				let containsSectionNames = Set(self.sectionsManager.sections.compactMap { $0.name })
				
				newSectionNames.subtract(containsSectionNames)
				
				var newSections = [SectionInfo<Entity>]()
				
				while !newSectionNames.isEmpty {
					
					let sectionName = newSectionNames.first!
					var filtered = newEntities.filter { $0[self.sectionKey!] == sectionName }
					
					if let sortEntities = self.sortEntities {
						filtered.sort(by: sortEntities)
					}
					
					let indexTitle = self.sectionIndexTitle(forSectionName: sectionName)
					let newSection = self.sectionsManager.newSection(with: filtered, name: sectionName, indexTitle: indexTitle)
					newSections.append(newSection)
					
					newSectionNames.remove(sectionName)
					
					for entity in filtered {
						newEntities.remove(at: newEntities.index(of: entity)!)
					}
					
				}
				
				self.sectionsManager.append(contentsOf: newSections)
				
				if let sortSections = self.sortSections {
					_ = self.sectionsManager.sortSections(by: sortSections)
				}
				
				if callModelDelegateMethods {
					for section in newSections {
						let sectionIndex = self.sectionsManager.index(of: section)
						self.model(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: sectionIndex)
					}
				}
				
				while !newEntities.isEmpty {
					
					let firstEntity = newEntities.first!
					let sectionName = firstEntity[self.sectionKey!]!
					let filtered = newEntities.filter { $0[self.sectionKey!] == sectionName }
					
					if self.sectionsManager.containsSection(with: sectionName) {
						let sectionIndex = self.sectionsManager.indexOfSection(withSectionName: sectionName)!
						insert(filtered, toSectionWithName: sectionName, sectionIndex: sectionIndex)
						
					}
					
					for entity in filtered {
						newEntities.remove(at: newEntities.index(of: entity)!)
					}
					
				}
				
			}
			
		}
		
		if callModelDelegateMethods {
			self.addModelOperation(with: BlockOperation(block: { (finished) in
				self.dispatchQueue.async(flags: .barrier) {
					inserMethod()
					finished()
				}
			})) {
				self.checkIsMainThread(isMainThread, completion: completion)
			}
			
		}
		else {
			self.addModelOperation(with: BlockOperation(block: { (finished) in
				self.dispatchQueue.async(flags: .barrier) {
					inserMethod()
					finished()
				}
			}), callDelegate: false) {
				self.checkIsMainThread(isMainThread, completion: completion)
			}
		}
		
	}
	
	//MARK: - Move methods
	
	public func moveEntity(at indexPath: IndexPath, to newIndexPath: IndexPath, isUserDriven: Bool, completion:(() -> ())?) {
		
		let isMainThread = Thread.isMainThread
		
		func moveMethod() {
			
			let entity = self.sectionsManager.remove(at: indexPath)
			self.sectionsManager.insert(entity, at: newIndexPath)
			
			if !isUserDriven {
				self.model(didChange: [entity], at: [indexPath], for: .move, newIndexPaths: [newIndexPath])
			}
			
		}
		
		if isUserDriven {
			self.addModelOperation(with: BlockOperation(block: { (finished) in
				self.dispatchQueue.async(flags: .barrier) {
					moveMethod()
					finished()
				}
			}), callDelegate: false) {
				self.checkIsMainThread(isMainThread, completion: completion)
			}
			
		}
		else {
			self.addModelOperation(with: BlockOperation(block: { (finished) in
				self.dispatchQueue.async(flags: .barrier) {
					moveMethod()
					finished()
				}
			})) {
				self.checkIsMainThread(isMainThread, completion: completion)
			}
		}
	}
	
	//MARK: - Update methods
	
	public func update(at indexPath: IndexPath, mutate: @escaping (inout Entity) -> Void, completion: (() -> Void)?) {
				
		guard let entity = self.sectionsManager[indexPath] else {
			fatalError("IndexPath is Out of range")
		}

		self.update(entity, mutate: mutate, completion: completion)
		
	}
	
	public func update(_ entity: Entity, mutate: @escaping (inout Entity) -> Void, completion: (() -> Void)?) {
		let isMainThread = Thread.isMainThread
		
		self.addModelOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				var mutateEntity = entity
				
				mutate(&mutateEntity)
				let indexPath = self.privateIndexPath(of: entity)!
				self.sectionsManager[indexPath] = mutateEntity
				self.model(didChange: [mutateEntity], at: [indexPath], for: .update, newIndexPaths: nil)
				
				finished()
			}
		}), callDelegate: false) {
			self.checkIsMainThread(isMainThread) {
				completion?()
			}
		}
		
	}
	
	
	//MARK: - Remove methods
	
	public func remove(at indexPath: IndexPath, completion: ((Entity) -> ())?) {
		let removeEmptySection: Bool = true
		let isMainThread = Thread.isMainThread
		
		var removedEntity: Entity!
		
		self.addModelOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				
				let sectionIndex = indexPath.section
				
				let entity = self.sectionsManager.remove(at: indexPath)
				removedEntity = entity
				
				if let index = self.entitiesUniqueValue.index(of: entity.uniqueValue) {
					self.entitiesUniqueValue.remove(at: index)
				}
				
				if removeEmptySection, let section = self.sectionsManager[sectionIndex], section.isEmpty {
					let section = self.sectionsManager.remove(at: sectionIndex)
					self.model(didChange: section, atSectionIndex: sectionIndex, for: .delete, newSectionIndex: nil)
				}
				else {
					self.model(didChange: [entity], at: [indexPath], for: .delete, newIndexPaths: nil)
				}
				
				finished()
			}
		})) {
			self.checkIsMainThread(isMainThread) {
				completion?(removedEntity)
			}
		}
		
	}
	
	public func remove(_ entity: Entity, completion: ((Entity) -> ())?) {
		
		if let indexPath = self.indexPath(of: entity) {
			self.remove(at: indexPath, completion: completion)
		}
		else {
			print("Index out of range")
		}
	}
	
	//	public func removeAllEntities(atSection sectionIndex: Int, completion: (() -> ())?) {
	//
	//		let isMainThread = Thread.isMainThread
	//
	//
	//		self.addModelOperation(with: BlockOperation(block: { (finished) in
	//			self.dispatchQueue.async(flags: .barrier) {
	//
	//				let entitiesToRemove = self.sectionsManager[sectionIndex]?.entities ?? []
	//				let lastIndex = entitiesToRemove.isEmpty ? 0 : entitiesToRemove.count-1
	//				let removedIndexPaths = IndexPath.indexPaths(in: 0...lastIndex, atSection: sectionIndex)
	//
	//				self.sectionsManager.remvoeAllEntities(atSection: sectionIndex)
	//
	//				self.model(didChange: entitiesToRemove, at: removedIndexPaths, for: .delete, newIndexPaths: nil)
	//
	//				finished()
	//
	//			}
	//		})) {
	//			self.checkIsMainThread(isMainThread) {
	//				completion?()
	//			}
	//		}
	//
	//	}
	
	public func removeSection(at sectionIndex: Int, completion: ((SectionInfo<Entity>) -> ())?) {
		
		let isMainThread = Thread.isMainThread
		
		var removedSection: SectionInfo<Entity>!
		
		self.addModelOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				
				let section = self.sectionsManager.remove(at: sectionIndex)
				self.model(didChange: section, atSectionIndex: sectionIndex, for: .delete, newSectionIndex: nil)
				removedSection = section
				finished()
			}
			
		})) {
			self.checkIsMainThread(isMainThread) {
				completion?(removedSection)
			}
		}
		
	}
	
	public func removeAll(completion: (() -> ())?) {
		
		let isMainThread = Thread.isMainThread
		
		self.addModelOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				
				self.sectionsManager.removeAll()
				finished()
			}
		}), callDelegate: false) {
			self.checkIsMainThread(isMainThread, completion: completion)
		}
		
	}
	
	//MARK: - Sort methods
	
	public func sortEntities(atSection sectionIndex: Int, by sort: @escaping ((Entity, Entity) -> Bool), completion: (() -> Void)?) {
		
		let isMainThread = Thread.isMainThread
		
		func sortMethod() {
			let entities = self.sectionsManager.entities(atSection: sectionIndex)
			let result = self.sectionsManager.sortEntities(atSection: sectionIndex, by: sort)
			self.model(didChange: entities, at: result.oldIndexPaths, for: .move, newIndexPaths: result.newIndexPaths)
		}
		
		self.addModelOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				sortMethod()
				finished()
			}
		})) {
			self.checkIsMainThread(isMainThread) {
				completion?()
			}
		}
	}
	
	public func reorder(completion: (() -> Void)?) {
		guard self.sortEntities != nil else { return }
		
		let firstIndex = 0
		let lastIndex = self.numberOfSections-1
		
		let isMainThread = Thread.isMainThread
		
		func sortMethod(forSection sectionIndex: Int) {
			let entities = self.sectionsManager.entities(atSection: sectionIndex)
			let result = self.sectionsManager.sortEntities(atSection: sectionIndex, by: self.sortEntities!)
			self.model(didChange: entities, at: result.oldIndexPaths, for: .move, newIndexPaths: result.newIndexPaths)
		}
		
		
		self.addModelOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				if lastIndex == 0 {
					sortMethod(forSection: firstIndex)
				}
				else {
					for index in firstIndex...lastIndex {
						sortMethod(forSection: index)
					}
				}
				
				finished()
			}
		})) {
			self.checkIsMainThread(isMainThread, completion: completion)
		}
		
	}
	
	public func sortSections(by sort: @escaping ((SectionInfo<Entity>, SectionInfo<Entity>) -> Bool), completion: (() -> Void)?) {
		
		let isMainThread = Thread.isMainThread
		
		self.addModelOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				let oldSections = self.sectionsManager.sections
				
				let result = self.sectionsManager.sortSections(by: sort)
				
				let oldIndexes = result.oldIndexes
				let newIndexes = result.newIndexes
				
				for i in 0...(oldSections.count-1) {
					let section = oldSections[i]
					let oldIndex = oldIndexes[i]
					let newIndex = newIndexes[i]
					self.model(didChange: section, atSectionIndex: oldIndex, for: .move, newSectionIndex: newIndex)
				}
				
				finished()
			}
		})) {
			self.checkIsMainThread(isMainThread) {
				completion?()
			}
		}
		
	}
	
	//MARK: - filter methods
	public func filteredEntities(atSection sectionIndex: Int, with filter: @escaping ((Entity) -> Bool)) -> [Entity] {
		var entities: [Entity]!
		self.dispatchQueue.sync {
			entities = self.sectionsManager.filteredEntities(atSection: sectionIndex, with: filter)
		}
		
		return entities ?? []
	}
	
	public func filteredEntities(with filter: @escaping ((Entity) -> Bool)) -> [Entity] {
		var entities: [Entity] = []
		
		self.dispatchQueue.sync {
			for i in 0...(self.numberOfSections-1) {
				let filtered = self.sectionsManager.filteredEntities(atSection: i, with: filter)
				entities.append(contentsOf: filtered)
			}
		}
		
		return entities
	}
	
	//MARK: - Get Section
	
	public func section(at sectionIndex: Int) -> SectionInfo<Entity>? {
		
		var section: SectionInfo<Entity>?
		
		self.dispatchQueue.sync {
			section = self.sectionsManager[sectionIndex]
		}
		
		return section
	}
	
	public func sectionIndexTitle(forSectionName sectionName: String) -> String? {
		guard self.sortSections != nil,
			!sectionName.isEmpty else { return nil }
		return self.delegate?.model(sectionIndexTitleForSectionName: sectionName)
	}
	
	public func section(forSectionIndexTitle title: String, at sectionIndex: Int) -> Int {
		guard let indexOfTitle = self.sectionIndexTitles.firstIndex(of: title),
			sectionIndex == indexOfTitle else {
				fatalError("wrong index title and section index")
		}
		
		var index = 0
		
		self.dispatchQueue.sync {
			for section in self.sectionsManager.sections {
				if section.indexTitle == title {
					index = self.sectionsManager.index(of: section)!
					break
				}
			}
		}
		
		return index
	}
	
	
	//MARK: - Get Entity
	
	public func entity(at indexPath: IndexPath) -> Entity? {
		
		var entity: Entity?
		
		self.dispatchQueue.sync {
			entity = self.sectionsManager[indexPath]
		}
		
		return entity
	}
	
	public func getAllEntities(sortedBy sort: ((Entity, Entity) -> Bool)?) -> [Entity] {
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
	
	private func modelWillChangeContent() {
		DispatchQueue.main.async {
			self.delegate?.modelWillChangeContent()
		}
	}
	
	private func modelDidChangeContent() {
		DispatchQueue.main.async {
			self.delegate?.modelDidChangeContent()
		}
	}
	
	private func model(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
		DispatchQueue.main.async {
			self.delegate?.model(didChange: entities, at: indexPaths, for: type, newIndexPaths: newIndexPaths)
		}
	}
	
	private func model(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) {
		DispatchQueue.main.async {
			self.delegate?.model(didChange: sectionInfo, atSectionIndex: sectionIndex, for: type, newSectionIndex: newSectionIndex)
		}
	}
	
	private func addModelOperation(with blockOperation: BlockOperation, callDelegate: Bool = true, completion: @escaping (() -> Void)) {
		let modelOperation = ModelOperation(delegate: self.delegate, callDelegate: callDelegate, blockOperation: blockOperation, completion: completion)
		
		self.operationQueue.addOperation(modelOperation)
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
