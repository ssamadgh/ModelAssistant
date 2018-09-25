/*
	ModelAssistant.swift
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

/*
Class Overview
==============

This class is intended to efficiently manage the results returned from an external source.

You configure an instance of this class optionally using a sectionKey. Also you can set filter, or some sorts for entities and sections. Then by calling the fetch method of the class and passing the entities you got from an external source, the instance starts to manipulate datas for you.
	You can insert, remove, change, or reorder entities without worrying about managing them in the model.

This class is tailored to work in conjunction with views that present collections of objects. These views typically expect their data source to present results as a list of sections made up of rows. ModelAssistant can efficiently analyze the datas you passed to it and pre-compute all the information about sections of the objects. In addition:
* The assistant monitors changes to objects its fetched, and reports changes to its delegate.
* All the methods of assistant are completely thread safe. So you can use methods to change objects in assistant and add or remove them in any thread and even concurrently, and the assistant executes your tasks, in order and updates your views that are adapted assistant delegate respectively.

Typical use
===========

Developers create an instance of ModelAssistant and configure it. It is expected that the sectionKey used in the instance, groups the results into sections. This allows for section information to be pre-computed.
After creating an instance, the fetch(_:completion:) method should be called to perform the fetching.
Once started, convenience methods on the instance can be used for configuring the initial state of the view.

You can use this class to mange databases like Json, PropertyList, etc. Also you can configure this class methods to works with datamodels like coredata, realm, etc. A delegate can be set on the class so that it's also notified when the result objects have changed. This would typically be used to update the display of the view.
WARNING: The assistant only performs change tracking if a delegate is set and responds to any of the change tracking notification methods.  See the ModelAssistantDelegate protocol for which delegate methods are change tracking.

*/

//MARK: - ModelAssistant class
/**
An assistant that you use to manage the results of an external source and display data to the user.

While table views can be used in several ways, modelAssistant primarily assist you with a master list view. UITableView expects its data source to provide cells as an array of sections made up of rows. You configure a modelAssistant, optionally with a sectionKey, filter and sort orders. The modelAssistant efficiently analyzes the input objects that you pass in it by calling fetch(_:completion:) method and computes all the information about sections of these objects. It also computes all the information for the index based on the fetched objects.

In addition:
* The assistant monitors changes to objects its fetched, and reports changes to its delegate.

* All the methods of assistant are completely thread safe. So you can use methods to change objects in assistant and add or remove them in any thread even concurrently, and the assistant executes your tasks, in order and updates your views that are adapted assistant delegate respectively.

An assistant thus effectively has two modes of operation, determined by whether it has a delegate:

* No tracking: The delegate is set to nil. The assistant simply provides access to the data as it was when the fetch method was executed.


* Memory tracking: the delegate is non-nil. The assistant monitors objects and updates section and ordering information in response to relevant changes.

- Important:
	The objects that passed in to the modelAssistant must be adapted **EntityProtocol & Hashable** protocols
*/
public final class ModelAssistant<Entity: EntityProtocol & Hashable>: NSObject, ModelAssistantProtocol {
	
	
	/* ========================================================*/
	/* ========================= INITIALIZERS ====================*/
	/* ========================================================*/
	
	/* Initializes an instance of ModelAssistant
	sectionKey - key on resulting objects that returns the section name. This will be used to pre-compute the section information.
	*/

	/**
	Returns a fetch request controller initialized using the given arguments.
	
	- Parameter sectionKey:
		A key on result objects that returns the section name. Pass nil to indicate that the controller should generate a single section.
	
		The section name is used to pre-compute the section information.
	*/
	public init(sectionKey: String?) {
		operationQueue.maxConcurrentOperationCount = 1
		self.sectionKey = sectionKey
		self.hasSection = sectionKey != nil
		self.sectionsManager = SectionsManager()
		super.init()
	}

	/// A DispatchQueue property that used to make implemention of methods thread safe.
	private let dispatchQueue = DispatchQueue(label: "com.model.ConcirrentGCD.DispatchQueue", attributes: DispatchQueue.Attributes.concurrent)
	
	/// An operation queue property that used to Prevents overlaping of delegate methods
	private let operationQueue = AOperationQueue()
	
	/**
	This property is used when you load objects on screen with lazy loading technique.
	
	You should set the value of this property as the number of objects that you receive from your source in each turn. The value of this property is used to compute `lastFetchIndex` and `nextFetchIndex` values.
	
	The default value of this property is 20.
	*/
	public var fetchBatchSize: Int = 20
	
	/**
	Use this subscript method to get the object corresponding to each indexPath.
	
	The result of this method is equivalent to `entity(at:)` method.
	
	- Parameter indexPath:
		The indexPath that you want object that corresponding to it.
	
	- Returns:
		The object corresponds to given indexPath or nil if nothing is found.
	*/
	public subscript(indexPath: IndexPath) -> Entity? {
		get {
			return self.entity(at: indexPath)
		}
	}
	
	/**
	Use this subscript method to get the section corresponding to each index.
	
	The result of this method is equivalent to `section(at:)` method.
	
	- Parameter index:
	The index that you want section that corresponding to it.
	
	- Returns:
	The section corresponds to given index or nil if nothing is found.
	*/
	public subscript(index: Int) -> SectionInfo<Entity>? {
		get {
			return self.section(at: index)
		}
	}
	
	/**
	The array of section index titles.
	
	The default implementation returns the array created by calling `sectionIndexTitle(forSectionName:)` on all the known sections. You should override this method if you want to return a different array for the section index.
	*/
	public var sectionIndexTitles: [String] {
		var titles: [String]!
		
		self.dispatchQueue.sync {
			titles = self.sectionsManager.sectionIndexTitles
		}
		
		return titles
	}
	
	/**
	The key on the fetched objects used to determine the section they belong to.
	*/
	public private (set) var sectionKey: String?
	
	/**
	The sort closure of entities.
	
	The sort entities closure specify how the objects passed into assistant should be ordered—for example, by last name and then by first name.
	
	A value of nil is treated as no sort entities.
	*/
	public var sortEntities: ((Entity, Entity) -> Bool)?
	
	/**
	The sort closure of sectoins.
	
	The sort sectoins closure specify how the sections should be ordered—for example, by the name.
	
	A value of nil is treated as no sort sections.
	*/
	public var sortSections: ((SectionInfo<Entity>, SectionInfo<Entity>) -> Bool)?
	
	/**
	The filter of the objects.
	
	The filter closure constrains the selection of objects the assistant instance is to fetch.
	
	A value of nil is treated as no filter.
	*/
	public var filter: ((Entity) -> Bool)?
	
	/// A Boolean value indicating whether the sectionKey is nil or not.
	private var hasSection: Bool
	
	/**
	An instance of SectionsManager.
	
	The section manager is a manager which is responsible for all the actions performed on the sections.
	In other words, the assistant has not any direct access to sections, instead it uses this instance to work with them.
	*/
	private var sectionsManager: SectionsManager<Entity>!
	
	/**
	The delegate that is notified when the fetched objects changed.
	
	If you do not specify a delegate, the assistant does not track changes to objects passed in it.
	
	- Note:
	You should consider this note each time you set a delegate for model assistant:
	
		Since the delegate methods should be implemented in the main thread and according to the way
		tableView and collectoinView update their rows and sections, the implementation of delegate
		methods called in each assistant method should not overlap. So, with calling each method of
		assistant, delegate methods are called in this way:
	
		1. `modelAssistantWillChange()` will be called.
	
		2. The works related to the method being done and durring it `modelAssistant<Entity>(didChange:...)` methods will be called.
		3. `modelAssistantDidChange()` will be called.
		4. The completion closure of assistant method will be called.
	
	Note that:
	* Each of these steps will begin after the end of the previous phase.
	
	* The assistant methods are thread safe and you can call them even concurrently. But from the point of the assistant, to prevent of overlaping, the methods will be implemented, one after another.
	*/
	public weak var delegate: ModelAssistantDelegate?
	
	///The sections for the fetched objects.
	var sections: [SectionInfo<Entity>] {
		var sections: [SectionInfo<Entity>]!
		self.dispatchQueue.sync {
			sections = self.sectionsManager.sections
		}
		return sections
	}
	
	//	var entities: [Entity]
	
	
	/// A set of uniqueValues of fetched entities, that used to check whether the object is new or assistant has one copy of it!
	private var entitiesUniqueValue: Set<Int> = []
	
	/**
	A Boolean value indicating whether the assistant is empty.
	
	When you need to check whether assistant is empty, use the isEmpty property instead of checking that the count of objects is equal to zero.
	*/
	public var isEmpty: Bool {
		return sectionsManager.isEmpty
	}
	
	/**
	The number of sections in the assistant.
	
	You typically use the numberOfSections property when implementing UITableViewDataSource (or UICollectionViewDataSource) methods, such as `numberOfSections(in:)`
	*/
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
	
	/**
	Number of all entities fetched with model assistant
	*/
	public var numberOfWholeEntities: Int {
		var numberOfWholeEntities: Int = 0
		
		self.dispatchQueue.sync {
			for section in self.sections {
				numberOfWholeEntities += section.numberOfEntities
			}
		}
		
		return numberOfWholeEntities
	}
	
	
	/**
	The number of entites (rows) in the given section.
	
	You typically use the numberOfSections property when implementing UITableViewDataSource (or UICollectionViewDataSource) methods, such as `tableView(_:, numberOfRowsInSection:) -> Int`
	*/
	public func numberOfEntites(at sectionIndex: Int) -> Int {
		var numberOfEntites: Int!
		
		self.dispatchQueue.sync {
			numberOfEntites = self.sectionsManager.numberOfEntites(at: sectionIndex)
		}
		
		return numberOfEntites
	}
	
	///	A Boolean value indicating whether the entitiesUnique is empty.
	private var entitiesUniqueValueIsEmpty: Bool {
		var isEmpty = false
		
		self.dispatchQueue.sync {
			isEmpty = self.entitiesUniqueValue.isEmpty
		}
		
		return isEmpty
	}
	
	
	public var lastFetchIndex: Int {
		guard fetchBatchSize != 0 else { return 0}
		let subtract = numberOfFetchedEntities/fetchBatchSize
		return numberOfFetchedEntities%fetchBatchSize == 0 ? subtract - 1 : subtract
	}
	
	
	public var nextFetchIndex: Int {
		guard fetchBatchSize != 0 else { return 0}
		guard !entitiesUniqueValueIsEmpty else { return 0 }
		return numberOfFetchedEntities%fetchBatchSize == 0 ? lastFetchIndex + 1 : lastFetchIndex
	}
	
	
	private var numberOfLastFetchedEntities: Int {
		guard fetchBatchSize != 0 else { return numberOfFetchedEntities }
		let numberOfEntities = self.numberOfFetchedEntities
		if numberOfEntities == 0 { return 0 }
		let lastCompleteIndex = Int(floor(Double(numberOfEntities)/Double(self.fetchBatchSize)))
		let diff = numberOfEntities - lastCompleteIndex*self.fetchBatchSize
		return diff == 0 ? self.fetchBatchSize : diff
	}
	
	/**
	Returns the lowest index whose corresponding section that is equal to a given section.
	
	- Parameter section: A section
	- Returns:
	The lowest index whose corresponding section is equal to given section. If none of the sections in the assistant is equal to section, returns NSNotFound.
	*/
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
		
		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			
			self.dispatchQueue.async(flags: .barrier) {
				
				let sectionIndex = indexPath.section
				let diff = self.sectionsManager.numberOfSections - sectionIndex
				
				if diff >= 0 {
					if diff == 0 {
						let sectionName = self.hasSection ? newEntity[self.sectionKey!]! : ""
						let indexTitle = self.sectionIndexTitle(forSectionName: sectionName)
						let section = self.sectionsManager.newSection(with: [newEntity], name: sectionName, indexTitle: indexTitle)
						self.sectionsManager.insert(section, at: sectionIndex)
						
						self.modelAssistant(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: sectionIndex)
					}
					else {
						self.sectionsManager.insert(newEntity, at: indexPath)
						
						self.modelAssistant(didChange: [newEntity], at: nil, for: .insert, newIndexPaths: [indexPath])
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
		self.insert(entities, callDelegateMethods: false, completion: completion)
	}
	
	public func insert(_ newEntities: [Entity], completion:(() -> ())?) {
		self.insert(newEntities, callDelegateMethods: true, completion: completion)
	}
	
	
	
	private func insert(_ newEntities: [Entity], callDelegateMethods: Bool, completion:(() -> ())?) {
		
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
				if let updated = result.updated, callDelegateMethods {
					
					self.modelAssistant(didChange: updated.entities, at: updated.indexPaths, for: .update, newIndexPaths: nil)
				}
				
				if let inserted = result.inserted {
					
					
					if self.sortEntities == nil {
						if callDelegateMethods {
							self.modelAssistant(didChange: inserted.entities, at: nil, for: .insert, newIndexPaths: inserted.indexPaths)
						}
					}
					else {
						
						_ = self.sectionsManager.sortEntities(atSection: sectionIndex, by: self.sortEntities!)
						
						if callDelegateMethods {
							var newIndexPaths: [IndexPath] = []
							
							for entity in inserted.entities {
								newIndexPaths.append(self.sectionsManager.indexPath(of: entity, atSection: sectionIndex)!)
							}
							self.modelAssistant(didChange: inserted.entities, at: nil, for: .insert, newIndexPaths: newIndexPaths)
							
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
				
				if callDelegateMethods {
					self.modelAssistant(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: sectionIndex)
					
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
				
				if callDelegateMethods {
					for section in newSections {
						let sectionIndex = self.sectionsManager.index(of: section)
						self.modelAssistant(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: sectionIndex)
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
		
		if callDelegateMethods {
			self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
				self.dispatchQueue.async(flags: .barrier) {
					inserMethod()
					finished()
				}
			})) {
				self.checkIsMainThread(isMainThread, completion: completion)
			}
			
		}
		else {
			self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
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
				self.modelAssistant(didChange: [entity], at: [indexPath], for: .move, newIndexPaths: [newIndexPath])
			}
			
		}
		
		if isUserDriven {
			self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
				self.dispatchQueue.async(flags: .barrier) {
					moveMethod()
					finished()
				}
			}), callDelegate: false) {
				self.checkIsMainThread(isMainThread, completion: completion)
			}
			
		}
		else {
			self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
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
		
		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				var mutateEntity = entity
				
				mutate(&mutateEntity)
				let indexPath = self.privateIndexPath(of: entity)!
				self.sectionsManager[indexPath] = mutateEntity
				self.modelAssistant(didChange: [mutateEntity], at: [indexPath], for: .update, newIndexPaths: nil)
				
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
		
		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				
				let sectionIndex = indexPath.section
				
				let entity = self.sectionsManager.remove(at: indexPath)
				removedEntity = entity
				
				if let index = self.entitiesUniqueValue.index(of: entity.uniqueValue) {
					self.entitiesUniqueValue.remove(at: index)
				}
				
				if removeEmptySection, let section = self.sectionsManager[sectionIndex], section.isEmpty {
					let section = self.sectionsManager.remove(at: sectionIndex)
					self.modelAssistant(didChange: section, atSectionIndex: sectionIndex, for: .delete, newSectionIndex: nil)
				}
				else {
					self.modelAssistant(didChange: [entity], at: [indexPath], for: .delete, newIndexPaths: nil)
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
		
		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				
				let section = self.sectionsManager.remove(at: sectionIndex)
				self.modelAssistant(didChange: section, atSectionIndex: sectionIndex, for: .delete, newSectionIndex: nil)
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
		
		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
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
			self.modelAssistant(didChange: entities, at: result.oldIndexPaths, for: .move, newIndexPaths: result.newIndexPaths)
		}
		
		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
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
			self.modelAssistant(didChange: entities, at: result.oldIndexPaths, for: .move, newIndexPaths: result.newIndexPaths)
		}
		
		
		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
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
		
		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				let oldSections = self.sectionsManager.sections
				
				let result = self.sectionsManager.sortSections(by: sort)
				
				let oldIndexes = result.oldIndexes
				let newIndexes = result.newIndexes
				
				for i in 0...(oldSections.count-1) {
					let section = oldSections[i]
					let oldIndex = oldIndexes[i]
					let newIndex = newIndexes[i]
					self.modelAssistant(didChange: section, atSectionIndex: oldIndex, for: .move, newSectionIndex: newIndex)
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
		return self.delegate?.modelAssistant(sectionIndexTitleForSectionName: sectionName)
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
	
	private func modelAssistantWillChangeContent() {
		DispatchQueue.main.async {
			self.delegate?.modelAssistantWillChangeContent()
		}
	}
	
	private func modelAssistantDidChangeContent() {
		DispatchQueue.main.async {
			self.delegate?.modelAssistantDidChangeContent()
		}
	}
	
	private func modelAssistant(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelAssistantChangeType, newIndexPaths: [IndexPath]?) {
		DispatchQueue.main.async {
			self.delegate?.modelAssistant(didChange: entities, at: indexPaths, for: type, newIndexPaths: newIndexPaths)
		}
	}
	
	private func modelAssistant(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelAssistantChangeType, newSectionIndex: Int?) {
		DispatchQueue.main.async {
			self.delegate?.modelAssistant(didChange: sectionInfo, atSectionIndex: sectionIndex, for: type, newSectionIndex: newSectionIndex)
		}
	}
	
	private func addModelAssistantOperation(with blockOperation: BlockOperation, callDelegate: Bool = true, completion: @escaping (() -> Void)) {
		let modelOperation = ModelAssistantOperation(delegate: self.delegate, callDelegate: callDelegate, blockOperation: blockOperation, completion: completion)
		
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


public protocol ModelAssistantDelegate: class {
	
	func modelAssistantWillChangeContent()
	
	func modelAssistantDidChangeContent()
	
	func modelAssistant<Entity: EntityProtocol & Hashable>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelAssistantChangeType, newIndexPaths: [IndexPath]?)
	
	func modelAssistant<Entity: EntityProtocol & Hashable>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelAssistantChangeType, newSectionIndex: Int?)
	
	func modelAssistant(sectionIndexTitleForSectionName sectionName: String) -> String?
}


public extension ModelAssistantDelegate {
	
	func modelAssistantWillChangeContent() {
		
	}
	
	func modelAssistantDidChangeContent() {
		
	}
	
	func modelAssistant<Entity: EntityProtocol & Hashable>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelAssistantChangeType, newIndexPaths: [IndexPath]?) {
		
	}
	
	func modelAssistant<Entity: EntityProtocol & Hashable>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelAssistantChangeType, newSectionIndex: Int?) {
		
	}
	
	func modelAssistant(sectionIndexTitleForSectionName sectionName: String) -> String? {
		return String(Array(sectionName)[0]).uppercased()
	}
	
}


/// Constants that specify the possible types of changes that are reported.
public enum ModelAssistantChangeType {
	
	/// Specifies that an object was inserted.
	case insert
	
	/// Specifies that an object was deleted.
	case delete
	
	/// Specifies that an object was moved.
	case move
	
	/// Specifies that an object was changed.
	case update
}
