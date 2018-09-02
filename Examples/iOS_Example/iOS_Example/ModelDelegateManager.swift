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
	
	func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
	
	func update(indexPath: IndexPath)
	
	func insertSection(_ section: Int)
	
	func deleteSection(_ section: Int)
	
	func moveSection(_ section: Int, toSection newSection: Int)
	
}


class ModelDelegateManager: ModelDelegate {

	var controller: CollectionController

	init(controller: CollectionController) {
		self.controller = controller
	}


	func modelWillChangeContent(for type: ModelChangeType) {

	}

	func modelDidChangeContent(for type: ModelChangeType) {

	}

	func model(didChange entities: [EntityProtocol], at indexPaths: [IndexPath]?, for type: ModelChangeType, newIndexPaths: [IndexPath]?) {
		switch type {
		case .insert:
			self.controller.insert(at: newIndexPaths!)
		case .update:
			print("")
		default:
			break
		}
	}

	func model(didChange sectionInfo: ModelSectionInfo, atSectionIndex sectionIndex: Int?, for type: ModelChangeType, newSectionIndex: Int?) {

	}

}




