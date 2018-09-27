//
//  PaginationCollectionViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PaginationPhoneBookCVC: SectionedPhoneBookCVC {
	
	var insertingNewEntities = false

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.rightBarButtonItem = nil
		self.title = "Pagination Phone Book"
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: sectionKey)
		self.assistant.fetchBatchSize = 20
	}
	
	override func fetchEntities() {
		self.resourceFileName = "PhoneBook_0"
		super.fetchEntities()
	}
	
	func insertEntities(from fileName: String) {
		
		guard !insertingNewEntities else {
			return
		}
		
		let tableViewHeight = self.collectionView!.bounds.height
		let maxOffsetHeight = self.collectionView!.contentSize.height - tableViewHeight
		let offsetY = self.collectionView!.contentOffset.y
		
		if offsetY >= maxOffsetHeight {
			
			guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else { return }
			let json = try! Data(contentsOf: url)
			
			let decoder = JSONDecoder()
			let members = try! decoder.decode([Contact].self, from: json)
			self.insertingNewEntities = true
			self.assistant.insert(members) {
				self.insertingNewEntities = false
			}
		}
	}
	
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
		if !decelerate {
			self.insertEntities(from: "PhoneBook_\(self.assistant.nextFetchIndex)")
		}
	}
	
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		super.scrollViewDidEndDecelerating(scrollView)
		self.insertEntities(from: "PhoneBook_\(self.assistant.nextFetchIndex)")
	}
	
}
