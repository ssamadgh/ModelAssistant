//
//  ModelProtocol.swift
//  Model
//
//  Created by Seyed Samad Gholamzadeh on 9/13/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

public protocol ModelProtocol {
	
	associatedtype Entity: EntityProtocol & Hashable
	
	var fetchBatchSize: Int { get set }
	
	subscript(indexPath: IndexPath) -> Entity? { get }
	
	subscript(index: Int) -> ModelSectionInfo?  { get }
	
	var sectionKey: String? { get set }
	
	var sortEntities: ((Entity, Entity) -> Bool)? { get set }
	
	var sortSections: ((ModelSectionInfo, ModelSectionInfo) -> Bool)? { get set }
	
	var filter: ((Entity) -> Bool)? { get set }
	
	var delegate: ModelDelegate? { get set }
	
	var isEmpty: Bool { get }
	
	var numberOfSections: Int { get }
	
	var numberOfWholeEntities: Int { get }
	
	func numberOfEntites(at sectionIndex: Int) -> Int
	
	var lastIndex: Int { get }
	
	var nextIndex: Int { get }
	
	func index(of section: ModelSectionInfo) -> Int?
	
	func indexPath(of entity: Entity) -> IndexPath?
	
	func indexPathOfEntity(withUniqueValue uniqueValue: Int) -> IndexPath?
	
	
	//MARK: - Insert methods

	func insertAtFirst(_ newEntity: Entity, completion:(() -> ())?)
	
	func insert(_ newEntity: Entity, at indexPath: IndexPath, completion:(() -> ())?)
	
	func insertAtLast(_ newEntity: Entity, completion:(() -> ())?)
	
	func fetch(_ entities: [Entity], completion:(() -> ())?)
	
	func insert(_ newEntities: [Entity], completion:(() -> ())?)
	
	
	//MARK: - Move methods

	func moveEntity(at indexPath: IndexPath, to newIndexPath: IndexPath, isUserDriven: Bool, completion:(() -> ())?)
	
	
	//MARK: - Update methods

	func update(at indexPath: IndexPath, mutate: @escaping (inout Entity) -> Void, completion: (() -> Void)?)
	
	func update(_ entity: Entity, mutate: @escaping (inout Entity) -> Void, completion: (() -> Void)?)
	
	
	//MARK: - Remove methods

	func remove(at indexPath: IndexPath, removeEmptySection: Bool, completion: ((Entity) -> ())?)
	
	func remove(_ entity: Entity, removeEmptySection: Bool, completion: ((Entity) -> ())?)
	
	func removeAllEntities(atSection sectionIndex: Int, completion: (() -> ())?)
	
	func removeSection(at sectionIndex: Int, completion: ((ModelSectionInfo) -> ())?)
	
	func removeAll(completion: (() -> ())?)
	
	
	//MARK: - Sort methods

	func sortEntities(atSection sectionIndex: Int, by sort: @escaping ((Entity, Entity) -> Bool), completion: (() -> Void)?)
	
	func reorder(completion: (() -> Void)?)
	
	func sortSections(by sort: @escaping ((ModelSectionInfo, ModelSectionInfo) -> Bool), completion: (() -> Void)?)

	
	//MARK: - filter methods

	func filteredEntities(atSection sectionIndex: Int, with filter: ((Entity) -> Bool)) -> [Entity]
	
	func filteredEntities(with filter: ((Entity) -> Bool)) -> [Entity]
	
	
	//MARK: - Get Section
	
	func section(at sectionIndex: Int) -> ModelSectionInfo?

	
	//MARK: - Get Entity

	func entity(at indexPath: IndexPath) -> Entity?
	
	func getAllEntities(sortedBy sort: ((Entity, Entity) -> Bool)?) -> [Entity]

	
	
}
