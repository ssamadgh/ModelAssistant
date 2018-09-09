//
//  ControllerProtocol.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

protocol CollectionController {
	
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


class ModelDelegateManager: ModelDelegate {
	var blockOperations: [BlockOperation] = []
	
	var controller: CollectionController
	
	init(controller: CollectionController) {
		self.controller = controller
	}
	
	
	func addToBlockOperation(_ operation: @escaping () -> Void) {
		
		let operation = BlockOperation {
				operation()
		}
		
		blockOperations.append(operation)
	}
	
	func modelWillChangeContent(for type: ModelChangeType) {
		
	}
	
	func model(didChange entities: [EntityProtocol], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
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
	
	func model(didChange sectionInfo: ModelSectionInfo, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) {
		
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
	
	func modelDidChangeContent(for type: ModelChangeType) {
		
		self.controller.performBatchUpdates({
			for operation: BlockOperation in self.blockOperations {
				operation.start()
			}
			
		}) { (finished) in
			self.blockOperations.removeAll(keepingCapacity: false)
		}
	}

	
}




