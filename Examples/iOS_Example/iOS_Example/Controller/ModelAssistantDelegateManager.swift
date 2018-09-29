//
//  ControllerProtocol.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

/*
Abstract:
	In this file we created a mechanism to use `performBatchUpdates(_:completion:)` method for implementing ModelAssistantDelegate methods
*/

import ModelAssistant

/**
	The CollectionController protocol is an abstract of methods that each collection view needs for interacting with its datasource. This protocol makes ModelAssistantDelegateManager class independent of ViewControllers.
	Any ViewController that uses ModelAssistantDelegateManager to implement ModelAssistantDelegate methods, must adopt this protocol.
*/
protocol CollectionController: class {
	
	func insert(at indexPaths: [IndexPath])
	
	func delete(at indexPaths: [IndexPath])
	
	func move(at indexPath: IndexPath, to newIndexPath: IndexPath)
	
	func update(at indexPath: IndexPath)
	
	func insertSection(_ section: Int)
	
	func deleteSection(_ section: Int)
	
	func moveSection(_ section: Int, toSection newSection: Int)
	
	func reloadSection(_ section: Int)
	
	func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?)
}

/**
The ModelAssistantDelegateManager class uses `performBatchUpdates(_:completion:)` to implement ModelAssistantDelegate methods. The way it works is that, we collect all the notifications sending to ModelAssistantDelegate as BlockOperation in an array. Then, when modelAssistantDidChangeContent() called, we execute these blocks into the `performBatchUpdates(_:completion:)` updates block.
*/
class ModelAssistantDelegateManager: ModelAssistantDelegate {
	
	var blockOperations: [BlockOperation] = []
	
	unowned var controller: CollectionController
	
	init(controller: CollectionController) {
		self.controller = controller
	}
	
	
	func addToBlockOperation(_ operation: @escaping () -> Void) {
		
		let operation = BlockOperation {
			operation()
		}
		
		blockOperations.append(operation)
	}
	
	func modelAssistantWillChangeContent() {
		
	}
	
	
	func modelAssistant<Entity>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelAssistantChangeType, newIndexPaths: [IndexPath]?) where Entity : MAEntity, Entity : Hashable {
		switch type {
			
		case .insert:
			
			self.addToBlockOperation { [weak self] in
				guard let `self` = self else { return }
				if let newIndexPaths = newIndexPaths {
					self.controller.insert(at: newIndexPaths)
				}
			}
			
		case .update:
			
			if let indexPaths = indexPaths {
				for indexPath in indexPaths {
					self.controller.update(at: indexPath)
				}
			}
			
		case .move:
			
			self.addToBlockOperation { [weak self] in
				guard let `self` = self else { return }
				
				if let indexPaths = indexPaths {
					for i in 0..<indexPaths.count {
						let indexPath = indexPaths[i]
						let newIndexPath = newIndexPaths![i]
						self.controller.move(at: indexPath, to: newIndexPath)
					}
				}
				
			}
			
		case .delete:
			
			self.addToBlockOperation { [weak self] in
				guard let `self` = self else { return }
				if let indexPaths = indexPaths {
					self.controller.delete(at: indexPaths)
				}
			}
			
		}
	}
	
	func modelAssistant<Entity>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelAssistantChangeType, newSectionIndex: Int?) where Entity : MAEntity, Entity : Hashable {
		switch type {
		case .insert:
			
			self.addToBlockOperation { [weak self] in
				guard let `self` = self else { return }
				if let newIndex = newSectionIndex {
					self.controller.insertSection(newIndex)
				}
			}
			
		case .update:
			
			self.addToBlockOperation { [weak self] in
				guard let `self` = self else { return }
				if let section = sectionIndex {
					self.controller.reloadSection(section)
				}
			}
			
		case .move:
			
			self.addToBlockOperation { [weak self] in
				guard let `self` = self else { return }
				if let index = sectionIndex, let newIndex = newSectionIndex {
					self.controller.moveSection(index, toSection: newIndex)
				}
			}
			
		case .delete:
			
			self.addToBlockOperation { [weak self] in
				guard let `self` = self else { return }
				if let index = sectionIndex {
					self.controller.deleteSection(index)
				}
			}
			
		}
	}
	
	func modelAssistantDidChangeContent() {		
		self.controller.performBatchUpdates({
			for operation: BlockOperation in self.blockOperations {
				
				// We directly call `start()` method of BlockOperations instead of adding them to a queue, so they execute in the main thread.
				operation.start()
			}
			
		}) { (finished) in
			self.blockOperations.removeAll(keepingCapacity: false)
		}
	}
	
	func modelAssistant(sectionIndexTitleForSectionName sectionName: String) -> String? {
		return String(Array(sectionName)[0]).uppercased()
	}
	
}




