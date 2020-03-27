//
//  UICollectionViewController+Extension.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

public protocol MACollectionViewContainer: MACollectionController {

	var collectionView: UICollectionView! { get set }

	func update(_ cell: UICollectionViewCell, at indexPath: IndexPath)
}

extension MACollectionViewContainer {

	public func maInsert(at indexPaths: [IndexPath]) {
		self.collectionView?.insertItems(at: indexPaths)
	}

	public func maUpdate(at indexPath: IndexPath) {
		if let cell = self.collectionView?.cellForItem(at: indexPath) {
			self.update(cell, at: indexPath)

		}
	}

	public func maDelete(at indexPaths: [IndexPath]) {
		self.collectionView?.deleteItems(at: indexPaths)
	}

	public func maMove(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		self.collectionView?.moveItem(at: indexPath, to: newIndexPath)
	}

	public func maInsertSections(_ sections: IndexSet) {
		self.collectionView?.insertSections(sections)
	}

	public func maDeleteSections(_ sections: IndexSet) {
		self.collectionView?.deleteSections(sections)
	}

	public func maMoveSection(_ section: Int, toSection newSection: Int) {
		self.collectionView?.moveSection(section, toSection: newSection)
	}

	public func maReloadSections(_ sections: IndexSet) {
		self.collectionView?.reloadSections(sections)
	}

	public func maPerformBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
		self.collectionView?.performBatchUpdates(updates, completion: completion)
	}

}


extension UICollectionViewController: MACollectionViewContainer {


	@objc open func update(_ cell: UICollectionViewCell, at indexPath: IndexPath) {

	}

}

