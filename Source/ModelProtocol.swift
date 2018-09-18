//
//  ModelProtocol.swift
//  Model
//
//  Created by Seyed Samad Gholamzadeh on 9/13/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

public protocol ModelProtocol {
	
	associatedtype Entity
	
	associatedtype SortEntities

	associatedtype SortSections

	associatedtype Section
	
	associatedtype Filter
		
	var fetchBatchSize: Int { get set }
	
	subscript(indexPath: IndexPath) -> Entity? { get }
	
	subscript(index: Int) -> Section?  { get }
	
	var sectionKey: String? { get }
	
	var sortEntities: SortEntities? { get set }
	
	var sortSections: SortSections? { get set }
	
	var filter: Filter? { get set }
	
	var delegate: ModelDelegate? { get set }
	
	var isEmpty: Bool { get }
	
	var numberOfSections: Int { get }
	
	var numberOfWholeEntities: Int { get }
	
	func numberOfEntites(at sectionIndex: Int) -> Int
	
//	var lastIndex: Int { get }
//	
//	var nextIndex: Int { get }
	
	func index(of section: Section) -> Int?
	
	func indexPath(of entity: Entity) -> IndexPath?
	
	
	//MARK: - Insert methods

//	func insertAtFirst(_ newEntity: Entity, completion:(() -> ())?)
	
	func insert(_ newEntity: Entity, at indexPath: IndexPath, completion:(() -> ())?)
	
//	func insertAtLast(_ newEntity: Entity, completion:(() -> ())?)
	
	func fetch(_ entities: [Entity], completion:(() -> ())?)
	
	func insert(_ newEntities: [Entity], completion:(() -> ())?)
	
	
	//MARK: - Move methods

	func moveEntity(at indexPath: IndexPath, to newIndexPath: IndexPath, isUserDriven: Bool, completion:(() -> ())?)
	
	
	//MARK: - Update methods

	func update(at indexPath: IndexPath, mutate: @escaping (inout Entity) -> Void, completion: (() -> Void)?)
	
	func update(_ entity: Entity, mutate: @escaping (inout Entity) -> Void, completion: (() -> Void)?)
	
	
	//MARK: - Remove methods

	func remove(at indexPath: IndexPath, completion: ((Entity) -> ())?)
	
	func remove(_ entity: Entity, completion: ((Entity) -> ())?)
	
//	func removeAllEntities(atSection sectionIndex: Int, completion: (() -> ())?)
	
	func removeSection(at sectionIndex: Int, completion: ((Section) -> ())?)
	
	func removeAll(completion: (() -> ())?)
	
	
	//MARK: - Sort methods

	func sortEntities(atSection sectionIndex: Int, by sort: SortEntities, completion: (() -> Void)?)
	
	func reorder(completion: (() -> Void)?)
	
	func sortSections(by sort: SortSections, completion: (() -> Void)?)

	
	//MARK: - filter methods

	func filteredEntities(atSection sectionIndex: Int, with filter: Filter) -> [Entity]

	func filteredEntities(with filter: Filter) -> [Entity]
	
	
	//MARK: - Get Section
	
	func section(at sectionIndex: Int) -> Section?

	
	//MARK: - Get Entity

	func entity(at indexPath: IndexPath) -> Entity?
	
	func getAllEntities(sortedBy sort: SortEntities?) -> [Entity]
	
}

extension ModelProtocol {
	
	public subscript(indexPath: IndexPath) -> Entity? {
		get {
			return self.entity(at: indexPath)
		}
	}
	
	public subscript(index: Int) -> Section? {
		get {
			return self.section(at: index)
		}
	}
	
	
}

