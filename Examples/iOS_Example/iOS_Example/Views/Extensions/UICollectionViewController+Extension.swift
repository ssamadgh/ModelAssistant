//
//  UICollectionViewController+Extension.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

extension UICollectionViewController: CollectionController {
	
	func insert(at indexPaths: [IndexPath]) {
		self.collectionView?.insertItems(at: indexPaths)
	}
	
	func update(at indexPath: IndexPath) {
		if let cell = self.collectionView?.cellForItem(at: indexPath) {
			self.update(cell, at: indexPath)
			
		}
	}
	
	func delete(at indexPaths: [IndexPath]) {
		self.collectionView?.deleteItems(at: indexPaths)
	}
	
	func move(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		self.collectionView?.moveItem(at: indexPath, to: newIndexPath)
	}
	
	func insertSection(_ section: Int) {
		self.collectionView?.insertSections(IndexSet(integer: section))
	}
	
	func deleteSection(_ section: Int) {
		self.collectionView?.deleteSections(IndexSet(integer: section))
	}
	
	func moveSection(_ section: Int, toSection newSection: Int) {
		self.collectionView?.moveSection(section, toSection: newSection)
	}
	
	func reloadSection(_ section: Int) {
		self.collectionView?.reloadSections(IndexSet(integer: section))
	}
	
	func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
		self.collectionView?.performBatchUpdates(updates, completion: completion)
	}
	
	@objc func update(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
		
	}
	
}

