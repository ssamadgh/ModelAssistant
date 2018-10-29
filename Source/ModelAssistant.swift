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

//MARK: - ModelAssistant
/**
An assistant that you use to manage the results of an external source and display data to the user.

While table views can be used in several ways, modelAssistant primarily assist you with a master list view. UITableView expects its data source to provide cells as an array of sections made up of rows. You configure a modelAssistant, optionally with a sectionKey, filter and sort orders. The modelAssistant efficiently analyzes the input objects that you pass in it by calling `fetch(_:completion:)` method and computes all the information about sections of these objects. It also computes all the information for the index based on the fetched objects.

In addition:
* The assistant monitors changes to objects its fetched, and reports changes to its delegate.

* All the methods of assistant are completely thread safe. So you can use methods to change objects in assistant and add or remove them in any thread even concurrently, and the assistant executes your tasks, in order and updates your views that are adapted assistant delegate respectively.

An assistant thus effectively has two modes of operation, determined by whether it has a delegate:

* No tracking: The delegate is set to nil. The assistant simply provides access to the data as it was when the fetch method was executed.


* Memory tracking: the delegate is non-nil. The assistant monitors objects and updates section and ordering information in response to relevant changes.

- Important:
	The objects that passed in to the modelAssistant must be adapted **MAEntity & Hashable** protocols
*/
public final class ModelAssistant<Entity: MAEntity & Hashable>: NSObject, ModelAssistantProtocol {


	/* ========================================================*/
	/* ========================= INITIALIZERS ====================*/
	/* ========================================================*/

	/* Initializes an instance of ModelAssistant
	sectionKey - key on resulting objects that returns the section name. This will be used to pre-compute the section information.
	*/

	//MARK: - Initialization
	/**
	Returns a model assistant initialized using the given arguments.

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

	//MARK: - Properties
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

	The filter closure constraints the selection of objects the assistant instance is to fetch.

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
			numberOfWholeEntities = self.sections.reduce(0, { return $0 + $1.numberOfEntities })
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

	/**
	The index of last fetched objects.

	This property is used if you want load objects to view in lazy loading style.
	*/
	public var lastFetchIndex: Int {
		guard fetchBatchSize != 0 else { return 0}
		let subtract = numberOfFetchedEntities/fetchBatchSize
		return numberOfFetchedEntities%fetchBatchSize == 0 ? subtract - 1 : subtract
	}

	/**
	The index of next fetched entities.

	This property is used if you want load objects to view in lazy loading style
	*/
	public var nextFetchIndex: Int {
		guard fetchBatchSize != 0 else { return 0}
		guard !entitiesUniqueValueIsEmpty else { return 0 }
		return numberOfFetchedEntities%fetchBatchSize == 0 ? lastFetchIndex + 1 : lastFetchIndex
	}

	/**
	The number of entities assistant got in last fetch

	This property is used if you want load objects to view in lazy loading style
	*/
	private var numberOfLastFetchedEntities: Int {
		guard fetchBatchSize != 0 else { return numberOfFetchedEntities }
		let numberOfEntities = self.numberOfFetchedEntities
		if numberOfEntities == 0 { return 0 }
		let lastCompleteIndex = Int(floor(Double(numberOfEntities)/Double(self.fetchBatchSize)))
		let diff = numberOfEntities - lastCompleteIndex*self.fetchBatchSize
		return diff == 0 ? self.fetchBatchSize : diff
	}

	//MARK: - Section Index Retrieval
	/**
	Returns the lowest index whose corresponding section that is equal to a given section.

	- Parameter section: A section
	- Returns:
	The lowest index whose corresponding section is equal to given section. If none of the sections in the assistant is equal to section, returns nil.
	*/
	public func index(of section: SectionInfo<Entity>) -> Int? {
		var index: Int?

		self.dispatchQueue.sync {
			index = self.sectionsManager.firstIndex(of: section)
		}

		return index
	}

	/**
	Returns the lowest index whose corresponding section with a name that is equal to a given section name.

	- Parameter sectionName: A section name
	- Returns:
	The lowest index whose corresponding section with a name that is equal to given section name. If none of the sections in the assistant is equal to section, returns nil.
	*/
	public func indexOfSection(withSectionName sectionName: String) -> Int? {
		var index: Int?

		self.dispatchQueue.sync {
			index = self.sectionsManager.firstIndexOfSection(withSectionName: sectionName)
		}

		return index
	}

	//MARK: - IndexPath Retrieval

	private func indexPath(for entity: Entity, synchronous: Bool) -> IndexPath? {
		let sectionName = self.hasSection ? entity[self.sectionKey!] : nil
		var indexPath: IndexPath?

		func getIndexPath() {
			indexPath = self.sectionsManager.indexPath(of: entity, withSectionName: sectionName)
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

	/**
	Returns the index path of a given entity.

	- Parameter entity:
	An entity in the model assistant.

	- Returns:
	The index path of entity in the model assistant, or nil if entity could not be found.
	*/
	public func indexPath(for entity: Entity) -> IndexPath? {
		return self.indexPath(for: entity, synchronous: true)
	}

	/**
	Returns the index path of a given entity.

	- Parameter entity:
	An entity in the model assistant.

	- Returns:
	The index path of entity in the model assistant, or nil if entity could not be found.

	- Important: This method is not synchronous
	*/
	private func privateIndexPath(for entity: Entity) -> IndexPath? {
		return indexPath(for: entity, synchronous: false)
	}

	/**
	Returns the index path of an entity with given unique value.

	- Parameter uniqueValue:
	The uniqueValue property of entity. This value should be unique for each entity.

	- Returns:
	The index path of entity in the model assistant that its uniqueValue is equal to the given uniqueValue, or nil if entity could not be found.

	- Important: This method is not synchronous
	*/
	public func indexPathForEntity(withUniqueValue uniqueValue: Int) -> IndexPath? {
		return indexPathForEntity(withUniqueValue: uniqueValue, synchronous: true)
	}


	private func privateIndexPathForEntity(withUniqueValue uniqueValue: Int) -> IndexPath? {
		return indexPathForEntity(withUniqueValue: uniqueValue, synchronous: false)
	}

	private func indexPathForEntity(withUniqueValue uniqueValue: Int, synchronous: Bool) -> IndexPath? {
		var indexPath: IndexPath?

		func getIndexPath() {
			if self.entitiesUniqueValue.contains(uniqueValue) {

				if let sectionIndex = self.sectionsManager.sections.firstIndex(where: { $0.entities.contains { $0.uniqueValue == uniqueValue } }) {

					let section = self.sectionsManager.sections[sectionIndex]

					if let row = section.entities.firstIndex(where: { $0.uniqueValue == uniqueValue }) {
						indexPath = IndexPath(row: row, section: sectionIndex)
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

	//MARK: - Insert methods

	//	public func insertAtFirst(_ newEntity: Entity, completion:(() -> ())?) {
	//		self.insert(newEntity, at: IndexPath(row: 0, section: 0), completion: completion)
	//	}


	/**
	Inserts a new entity into the model assistant at the specified indexPath.


	- Parameters:
		- newEntity:
		The new entity to insert into the model assistant.

		- indexPath:
		The indexPath at which to insert the new entity. indexPath must be a valid indexPath into the model assistant.
	*/
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


	/**
	This method gots the given entities and inserts them in to model assistant according to section key, sorts and filter user has set, without calling delegate methods.
	- Important:
	Use this method at the begin of loading list view to set the initial values of view like number of sections, number of entities, etc.

	- Parameters:
		- entities:
		The new entities to insert into the model assistant.
		- completion:
		A block object to be executed when the insertion of entities ends.
		Note that, this block executes after the task of method in model assistant ends.
	*/
	public func fetch(_ entities: [Entity], completion:(() -> ())?) {
		self.insert(entities, callDelegateMethods: false, completion: completion)
	}

	/**
	This method gots the given entities and inserts them in to model assistant according to section key, sorts and filter user has set. This method calls delegate methods.
	- Important:
	Do not use this method at the begin of loading list view. Because in that time the view has not set the needed initial values (like number of sections, number of entities, etc) yet, and by calling this method you disrupt the work of view and your app gots crash. Use `fetch(_:, completion:)` method insetead.

	- Parameters:
		- newEntities:
		The new entities to insert into the model assistant.

		- completion:
		A block object to be executed when the insertion of entities ends.
		Note that, this block, executes after executing all the delegate methods.
	*/
	public func insert(_ newEntities: [Entity], completion:(() -> ())?) {
		self.insert(newEntities, callDelegateMethods: true, completion: completion)
	}


	/**
	This method gots the given entities and inserts them in to model assistant according to section key, sorts and filter user has set. This method calls delegate methods.

	- Parameters:
		- newEntities:
		The new entities to insert into the model assistant.

		- callDelegateMethods:
		Set true to call delegate method, else set it false

		- completion:
		A block object to be executed when the insertion of entities ends.
	*/
	private func insert(_ newEntities: [Entity], callDelegateMethods: Bool, completion:(() -> ())?) {

		let isMainThread = Thread.isMainThread

		func inserMethod() {

			let newEntitiesUniqueValue = Set(newEntities.map { $0.uniqueValue })

			self.entitiesUniqueValue.formUnion(newEntitiesUniqueValue)

			var newEntities = newEntities

			if self.filter != nil {
				newEntities = newEntities.filter(self.filter!)
			}

			if !self.hasSection {

				if self.sectionsManager.isEmpty {
					self.insertFirstNewSection(with: newEntities, callDelegateMethods: callDelegateMethods)
				}
				else {
					let sectionIndex: Int = 0
					self.insert(newEntities, toSectionAt: sectionIndex, callDelegateMethods: callDelegateMethods)
				}

			}
			else {
				
				let existSectionNames = Set(self.sectionsManager.sections.compactMap { $0.name })

				let newSections: [SectionInfo<Entity>]
				
				func newSection(withName sectionName: String) -> SectionInfo<Entity> {
					let index = newEntities.stablePartition { $0[self.sectionKey!] == sectionName }
					var sectionEntities = Array(newEntities[index...])
					newEntities.removeLast(sectionEntities.count)
					
					if let sortEntities = self.sortEntities {
						sectionEntities.sort(by: sortEntities)
					}
					
					let indexTitle = self.sectionIndexTitle(forSectionName: sectionName)
					let newSection = self.sectionsManager.newSection(with: sectionEntities, name: sectionName, indexTitle: indexTitle)
					return newSection
				}
				
				if let sortSections = self.sortSections {
					
					var newSectionNames = Set(newEntities.compactMap {  $0[self.sectionKey!] })
					
					
					newSectionNames.subtract(existSectionNames)
					
					var sectionsSet = Set<SectionInfo<Entity>>()
					
					while !newSectionNames.isEmpty {
						sectionsSet.insert(newSection(withName: newSectionNames.removeFirst() ))
					}
					
					self.sectionsManager.append(contentsOf: sectionsSet)
					_ = self.sectionsManager.sortSections(by: sortSections)
					newSections = Array(sectionsSet)

				}
				else {
					
					var newSectionNames = (newEntities.compactMap {  $0[self.sectionKey!] }).removingDuplicates()
					
					newSectionNames.removeAll { existSectionNames.contains($0) }
					
					var sectionsArray = [SectionInfo<Entity>]()
					
					while !newSectionNames.isEmpty {
						sectionsArray.append(newSection(withName: newSectionNames.removeLast() ))
					}
					
					sectionsArray.reverse()
					
					self.sectionsManager.append(contentsOf: sectionsArray)
					newSections = sectionsArray
				}

				if callDelegateMethods {
					
					newSections.forEach { section in
						let sectionIndex = self.sectionsManager.firstIndex(of: section)
						self.modelAssistant(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: sectionIndex)
					}
					
				}

				while !newEntities.isEmpty {
					let sectionName = newEntities.first![self.sectionKey!]!
					let index = newEntities.stablePartition { $0[self.sectionKey!] == sectionName }
					let sectionEntities = Array(newEntities[index...])
					
					newEntities.removeLast(sectionEntities.count)

					let sectionIndex = self.sectionsManager.firstIndexOfSection(withSectionName: sectionName)!
					self.insert(sectionEntities, toSectionAt: sectionIndex, callDelegateMethods: callDelegateMethods)

				}
				

			}

		}

		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				inserMethod()
				finished()
			}
		}), callDelegate: callDelegateMethods) {
			self.checkIsMainThread(isMainThread, completion: completion)
		}

	}

	internal func insertFirstNewSection(with newEntities: [Entity], callDelegateMethods: Bool) {
		var newEntities = newEntities
		
		if let sortEntities = self.sortEntities {
			newEntities.sort(by: sortEntities)
		}
		
		let section = self.sectionsManager.newSection(with: newEntities, name: "", indexTitle: nil)
		self.sectionsManager.append(section)
		
		if callDelegateMethods {
			self.modelAssistant(didChange: section, atSectionIndex: nil, for: .insert, newSectionIndex: 0)
		}
	}
	
	internal func insert(_ newEntities: [Entity], toSectionAt sectionIndex: Int, callDelegateMethods: Bool) {
		
		let result = self.sectionsManager.insert(newEntities, toSectionAt: sectionIndex)
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
					
					let newIndexPaths: [IndexPath] = inserted.entities.compactMap { self.sectionsManager.indexPath(of: $0, atSection: sectionIndex)! }
					
					self.modelAssistant(didChange: inserted.entities, at: nil, for: .insert, newIndexPaths: newIndexPaths)
				}
			}
			
		}
		
	}
	
	//MARK: - Move methods

	/**
	Move an entity at a specific indexPath in the model assistant to another indexPath.

	- Parameters:
		- indexPath: An index path locating the entity to be moved in assistant.
		- newIndexPath: An index path locating the place in model assistant that is the destination of the move.
		- isUserDriven:
		set This flag true if move is initiated by the user.
		In general, ModelAssistant is designed to respond to changes at the model layer. If you allow a user to reorder table rows in tableView, then your implementation of the delegate methods must take this into account.
		If you allow the user to reorder table rows, and then call this method, by default this causing the model assistant to notice the change, and so inform its delegate of the update (using modelAssistant(_:didChange:at:for:newIndexPath:)), then the delegate attempts to update the table view. The table view, however, is already in the appropriate state because of the user’s action.
			So by setting this flag true, model assistant bypass delegate methods and you avoiding this side effect.
		- completion:
		A block object to be executed when the task of method ends.
		Note that, if you set isUserDriven flag true, this block, executes after executing all the delegate methods, and if you set if you set isUserDriven flag false, this block executes after the task of method in model assistant ends.
	*/
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

	/**
	Updates the entity located at given indexPath

	Use this method to update entities that passed in model assistant. This method is thread safe,
	so you can update an entity in several thread concurrently and model assistant take care fo updating that entity safely.

	 - Parameters:
	   - indexPath: The index path of entity to be update.
	   - mutate: A black that gives you a mutate entity. Update properties of this entity directly and do not copy or replace it. the model assistant take care of update process.
	   - completion:
		A block object to be executed when the task of method ends.
		Note that, this block, executes after executing all the delegate methods.

	- important:
		* This method do not calls delegate `modelWillCahnge()` and `modelDidChange()` methods. Because by calling this two methods if you configured tableView by delegate methods, tableView reloads the cell that is connected to index path of updated entity. So if you want such situation configure it manually.
		* The indexpath that passed to delegate method which locates the place of updated entity is not necessarily equal to given indexpath to this method. Because the indexpath of the entity may be changed before update process be executed by other methods, and model assistant trace these changes.
	*/
	public func update(at indexPath: IndexPath, mutate: @escaping ((inout Entity) -> Void), completion: (() -> Void)?) {

		guard let entity = self.sectionsManager[indexPath] else {
			fatalError("IndexPath is Out of range")
		}

		self.update(entity, at: indexPath, mutate: mutate, completion: completion)

	}

	/**
	Updates the given entity, by given block

	Use this method to update entities that passed in model assistant. This method is thread safe,
	so you can update an entity in several thread concurrently and model assistant take care fo updating that entity safely.

	- important:
		* This method do not calls delegate `modelWillCahnge()` and `modelDidChange()` methods. Because by calling this two methods if you configured tableView by delegate methods, tableView reloads the cell that is connected to index path of updated entity. So if you want such situation configure it manually.

	- Parameters:
		- entity: The entity to be update.
		- mutate: A black that gives you a mutate entity. Update properties of this entity directly and do not copy or replace it. the model assistant take care of update process.
		- completion:
		A block object to be executed when the task of method ends.
		Note that, this block, executes after executing all the delegate methods.

	*/
	public func update(_ entity: Entity, mutate: @escaping ((inout Entity) -> Void), completion: (() -> Void)?) {

		guard let indexPath = self.privateIndexPath(for: entity) else {
			fatalError("entity is Out of access")
		}

		self.update(entity, at: indexPath, mutate: mutate, completion: completion)
	}


	private func update(_ entity: Entity, at indexPath: IndexPath, mutate: @escaping ((inout Entity) -> Void), completion: (() -> Void)?) {
		let isMainThread = Thread.isMainThread

		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {

				func update(_ entity: Entity, at indexPath: IndexPath) {
					var mutateEntity = entity

					mutate(&mutateEntity)
					self.sectionsManager[indexPath] = mutateEntity
					self.modelAssistant(didChange: [mutateEntity], at: [indexPath], for: .update, newIndexPaths: nil)
				}

				let afterIndexPath = self.privateIndexPath(for: entity)
				let afterEntity = self.sectionsManager[indexPath]

				if afterEntity == entity, afterIndexPath == indexPath {
					//State 1: The given entity not changed and not moved
					// continue update with entity
					update(afterEntity!, at: indexPath)
				}
				else if afterEntity?.uniqueValue == entity.uniqueValue {
						//State 2: The given entity has changed
						// Continue update with afterEntity
						update(afterEntity!, at: indexPath)

					}
					else {

						if let movedIndexPath = afterIndexPath {
							//State 3: The given entity has moved
							let movedEntity = self.sectionsManager[movedIndexPath]!
							// Continue update with entity
							update(movedEntity, at: movedIndexPath)

						}
						else {
							//State 4:
							// Maybe its main infos changed, let find it with its unique value
							if let movedIndexPath = self.privateIndexPathForEntity(withUniqueValue: entity.uniqueValue) {
								let movedEntity = self.sectionsManager[movedIndexPath]!
								// Continue update with entity
								update(movedEntity, at: movedIndexPath)
							}

						}

					}

				finished()

			}

		}), callDelegate: false) {
			self.checkIsMainThread(isMainThread) {
				completion?()
			}
		}


	}

	//MARK: - Remove methods

	/**
	 Removes the entity at the specified indexpath.

	 - Parameters:
	   - indexPath: The indexpath of the entity to remove. indexpath must be a valid indexPath of model assistant entities.
	   - completion:
		A block object to be executed when the task of method ends.
		This block contains removed entity.
		Note that, this block, executes after executing all the delegate methods.
	*/
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

	/**
	Removes the given entity.

	- Parameters:
		- entity: The the entity to remove.
		- completion:
		A block object to be executed when the task of method ends.
		This block contains removed entity.
		Note that, this block, executes after executing all the delegate methods.
	*/
	public func remove(_ entity: Entity, completion: ((Entity) -> ())?) {

		if let indexPath = self.indexPath(for: entity) {
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


	/**
	Removes All entities at the specified section index.

	- Parameters:
		- sectionIndex: The index of the section to remove. Index must be a valid index of the model assistant sections.
		- completion:
		A block object to be executed when the task of method ends.
		This block contains removed section.
		Note that, this block, executes after executing all the delegate methods.
	*/
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

	/**
	Removes All entities in model assistant.

	Use this method to reset model assistant. This method does not call any delegate method.

	- Parameters:
		- completion:
		A block object to be executed when the task of method ends.
		This block contains removed section.
		Note that, this block executes after the task of method in model assistant ends.
	*/
	public func removeAll(completion: (() -> ())?) {

		let isMainThread = Thread.isMainThread

		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				self.entitiesUniqueValue.removeAll()
				self.sectionsManager.removeAll()
				finished()
			}
		}), callDelegate: false) {
			self.checkIsMainThread(isMainThread, completion: completion)
		}

	}

	//MARK: - Sort methods

	/**
	Sort entities in the given section index by sort closure.

	Use this method to sort a specified section entities independent of other sections

	- Parameters:
		- sectionIndex: The section index of entities to be sort
		- sort: The sort closure of entities.
		- completion:
		A block object to be executed when the task of method ends.
		This block contains removed section.
		Note that, this block, executes after executing all the delegate methods.
	*/
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

	/**
	Reorders entities in all the sections based on `sortEntities` closure.

	Use this method if you changed the value of `sortEntities` to reorder entities in all the sections.

	- Parameters:
		- completion:
		A block object to be executed when the task of method ends.
		This block contains removed section.
		Note that, this block, executes after executing all the delegate methods.
	*/
	public func reorderEntities(completion: (() -> Void)?) {
		guard !self.isEmpty,  self.sortEntities != nil else { return }

		let firstIndex = 0
		let lastIndex = self.numberOfSections-1
		
		let isMainThread = Thread.isMainThread

		func sortMethod(forSectionAt sectionIndex: Int) {
			let entities = self.sectionsManager.entities(atSection: sectionIndex)
			let result = self.sectionsManager.sortEntities(atSection: sectionIndex, by: self.sortEntities!)
			self.modelAssistant(didChange: entities, at: result.oldIndexPaths, for: .move, newIndexPaths: result.newIndexPaths)
		}


		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				if lastIndex == 0 {
					sortMethod(forSectionAt: firstIndex)
				}
				else {
					(firstIndex...lastIndex).forEach { sortMethod(forSectionAt: $0) }
				}

				finished()
			}
		})) {
			self.checkIsMainThread(isMainThread, completion: completion)
		}

	}

	/**
	Reorders sections based on `sortSections` closure.

	Use this method if you changed the value `sortSections` to reorder sections in model assistant.

	- Parameters:
		- completion:
		A block object to be executed when the task of method ends.
		This block contains removed section.
		Note that, this block, executes after executing all the delegate methods.
	*/
	public func reorderSections(completion: (() -> Void)?) {
		guard let sortSections = self.sortSections else { return }

		self.sortSections(by: sortSections, completion: completion)
	}

	/**
	Sorts sections by the given sort closure.

	- Parameters:
		- sort: The sort closure of sections
		- completion:
		A block object to be executed when the task of method ends.
		This block contains removed section.
		Note that, this block, executes after executing all the delegate methods.
	*/

	public func sortSections(by sort: @escaping ((SectionInfo<Entity>, SectionInfo<Entity>) -> Bool), completion: (() -> Void)?) {

		let isMainThread = Thread.isMainThread

		self.addModelAssistantOperation(with: BlockOperation(block: { (finished) in
			self.dispatchQueue.async(flags: .barrier) {
				let oldSections = self.sectionsManager.sections

				let result = self.sectionsManager.sortSections(by: sort)

				let oldIndexes = result.oldIndexes
				let newIndexes = result.newIndexes

				(0...(oldSections.count-1)).forEach { i in
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

	/**
	Returns entities that satisfy filter closure conditions in the given section index.

	- Parameters:
	  - sectionIndex: The section index of entities to be filtered
	  - filter: The filter closure of entities
	- Returns: entities that satisfy filter closure conditions in the given section index.
	*/
	public func filteredEntities(atSection sectionIndex: Int, with filter: @escaping ((Entity) -> Bool)) -> [Entity] {
		var entities: [Entity]!
		self.dispatchQueue.sync {
			entities = self.sectionsManager.filteredEntities(atSection: sectionIndex, with: filter)
		}

		return entities ?? []
	}

	/**
	Returns entities that satisfy filter closure conditions among all the model assistant entities.

	- Parameters:
		- filter: The filter closure of entities
	- Returns: entities that satisfy filter closure conditions.
	*/
	public func filteredEntities(with filter: @escaping ((Entity) -> Bool)) -> [Entity] {
		return filteredEntities(with: filter, synchronous: true)
	}

	private func privateFilteredEntities(with filter: @escaping ((Entity) -> Bool)) -> [Entity] {

		return filteredEntities(with: filter, synchronous: false)
	}

	private func filteredEntities(with filter: @escaping ((Entity) -> Bool), synchronous: Bool) -> [Entity] {
		
		var entities: [Entity] = []

		func filterEntities() {
			entities = self.sectionsManager.filteredEntities(with: filter)
		}

		if synchronous {
			self.dispatchQueue.sync {
				filterEntities()
			}
		}
		else {
			filterEntities()
		}

		return entities
	}

	//MARK: - Section Retrieval

	/**
	Returns the section at the given index in the model assistant.

	- Parameter sectionIndex: A section index in the model assistant.

	- Returns: The section at the given section index in the model assistant.
	If section index does not describe a valid section index in the model assistant, returns nil.
	*/
	public func section(at sectionIndex: Int) -> SectionInfo<Entity>? {

		var section: SectionInfo<Entity>?

		self.dispatchQueue.sync {
			section = self.sectionsManager[sectionIndex]
		}

		return section
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
	Returns the corresponding section index entry for a given section name.

	This method calls `modelAssistant(sectionIndexTitleForSectionName sectionName: String) -> String?`. You should use this delegate method if you need a different way to convert from a section name to its name in the section index.

	- Parameter sectionName: The name of a section.
	- Returns: The section index entry corresponding to the section with name sectionName.
	*/
	public func sectionIndexTitle(forSectionName sectionName: String) -> String? {
		guard self.sortSections != nil,
			!sectionName.isEmpty else { return nil }
		return self.delegate?.modelAssistant(sectionIndexTitleForSectionName: sectionName)
	}

	/**
	Returns the section number for a given section title and index in the section index.

	You would typically call this method when executing UITableViewDataSource’s [tableView(_:sectionForSectionIndexTitle:at:)](https://developer.apple.com/documentation/uikit/uitableviewdatasource/1614933-tableview) method.

	- Parameters:
	  - title: The title of a section
	  - sectionIndex: The index of a section.
	- Returns: The section number for the given section title and index in the section index

	*/
	public func section(forSectionIndexTitle title: String, at sectionIndex: Int) -> Int {
		guard let indexOfTitle = self.sectionIndexTitles.firstIndex(of: title),
			sectionIndex == indexOfTitle else {
				fatalError("wrong index title and section index")
		}

		var index = 0

		self.dispatchQueue.sync {
			index = self.sectionsManager.firstSectionIndex(withSectionIndexTitle: title)
		}

		return index
	}


	//MARK: - Entity Retrieval

	/**
	Returns the entity at the given index path in the model assistant.

	- Parameter indexPath: An index path in the model assistant.
	- Returns: The entity at the given index path in the model assistant.
	If index path does not describe a valid index path in the model assistant, returns nil.

	*/
	public func entity(at indexPath: IndexPath) -> Entity? {

		var entity: Entity?

		self.dispatchQueue.sync {
			entity = self.sectionsManager[indexPath]
		}

		return entity
	}

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
	Returns all the entities in model assistant, sorted by given sort

	- Parameter sort: The sort closure of entities. leave this parameter nil, if you do not want to do any sort task on the returned entities.
	- Returns: All the entities in model assistant, sorted by given sort
	*/
	public func getAllEntities(sortedBy sort: ((Entity, Entity) -> Bool)?) -> [Entity] {
		var entities: [Entity] = []

		self.dispatchQueue.sync {
			entities = self.sectionsManager.allEntities()
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

	/**
	Notifies the receiver that the model assistant is about to start processing of one or more changes due to an add, remove, move, or update.

	This method is invoked before all invocations of modelAssistant(didChange:at:for:newIndexPath:) and modelAssistant(didChange:atSectionIndex:for:) have been sent for a given change event.
	*/
	func modelAssistantWillChangeContent()

	/**
	Notifies the receiver that the model assistant has completed processing of one or more changes due to an add, remove, move, or update.

	This method is invoked after all invocations of modelAssistant(didChange:at:for:newIndexPath:) and modelAssistant(didChange:atSectionIndex:for:) have been sent for a given change event.
	*/
	func modelAssistantDidChangeContent()

	/**
	Notifies the receiver that some of entities has been changed due to an add, remove, move, or update.

	User this method to change your collection view according to model assistant changes.
	- Important: The place of items in entities, indexPaths and newIndexPaths arrays are corresponds to eachother.

	- Parameters:
	- entities: The entities in model assistant that changed.
	- indexPaths: The index paths of the changed entities (this value is nil for insertions).
	- type: The type of change. For valid values see ModelAssistantChangeType.
	- newIndexPaths: The destination paths for the entities for insertions or moves (this value is nil for a deletion).
	*/
	func modelAssistant<Entity: MAEntity & Hashable>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelAssistantChangeType, newIndexPaths: [IndexPath]?)

	/**
	Notifies the receiver of the addition or removal of a section.

	- Parameters:
	- sectionInfo: The section that changed.
	- sectionIndex: The index of the changed section (this value is nil for insertions).
	- type: The type of change (insert or delete). Valid values are ModelAssistantChangeType.insert, ModelAssistantChangeType.move and ModelAssistantChangeType.delete.
	- newSectionIndex: The destination index for the section for insertions or moves (this value is nil for a deletion).
	*/
	func modelAssistant<Entity: MAEntity & Hashable>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelAssistantChangeType, newSectionIndex: Int?)

	/**
	Returns the name for a given section.

	This method does not enable change tracking. It is only needed if a section index is used.
	If the delegate doesn’t implement this method, the default implementation returns the capitalized first letter of the section name.

	- Parameter sectionName: The default name of the section.
	- Returns: The string to use as the name for the specified section.
	*/
	func modelAssistant(sectionIndexTitleForSectionName sectionName: String) -> String?
}

// This extension is used to makes methods of ModelAssistantDelegate protocol optional.
public extension ModelAssistantDelegate {

	func modelAssistantWillChangeContent() {

	}

	func modelAssistantDidChangeContent() {

	}

	func modelAssistant<Entity: MAEntity & Hashable>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelAssistantChangeType, newIndexPaths: [IndexPath]?) {

	}

	func modelAssistant<Entity: MAEntity & Hashable>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelAssistantChangeType, newSectionIndex: Int?) {

	}

	func modelAssistant(sectionIndexTitleForSectionName sectionName: String) -> String? {
		return String(Array(sectionName)[0]).uppercased()
	}

}


/// Constants that specify the possible types of changes that are reported.
public enum ModelAssistantChangeType {

	/// Specifies that an entity was inserted.
	case insert

	/// Specifies that an entity was deleted.
	case delete

	/// Specifies that an entity was moved.
	case move

	/// Specifies that an entity was changed.
	case update
}
