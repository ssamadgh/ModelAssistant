//
//  SearchablePhoneBookCVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import ModelAssistant

class SearchablePhoneBookCVC: SimplePhoneBookCVC {
	
	var searchResults: [Contact] = []
	
	var isSearching: Bool = false
	
	var searchController: UISearchController!

	override init() {
		super.init()
		(self.collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize.height = 40
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		#if swift(>=4.2)
		let supplementaryKind = UICollectionView.elementKindSectionHeader
		#else
		let supplementaryKind = UICollectionElementKindSectionHeader
		#endif

		self.collectionView?.register(UINib(nibName: "CollectionReusableView", bundle: nil), forSupplementaryViewOfKind: supplementaryKind, withReuseIdentifier: "header")

		super.viewDidLoad()
		self.title = "Searchable Phone Book"
		
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		self.configureSearchController()
		super.configureModelAssistant(sectionKey: "firstName")
		self.assistant.sortEntities = { $0.firstName < $1.firstName }
		self.assistant.sortSections = { $0.name < $1.name }
	}
	
	func configureSearchController() {
		self.searchController = UISearchController(searchResultsController: nil)
		self.searchController.searchResultsUpdater = self
		
		searchController.delegate = self
		searchController.dimsBackgroundDuringPresentation = false // default is YES
		searchController.searchBar.delegate = self    // so we can monitor text changes + others
		
		definesPresentationContext = true
		
		navigationController?.navigationBar.prefersLargeTitles = true
		
		navigationItem.searchController = searchController
		
		// We want the search bar visible all the time.
		navigationItem.hidesSearchBarWhenScrolling = false
	}
	
	// MARK: UICollectionViewDataSource

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionReusableView
		
		let section = self.assistant[indexPath.section]
		
		headerView.titleLabel.text = section?.name
		
		return headerView
	}


	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.isSearching ? 1 : super.numberOfSections(in: collectionView)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of items
		return self.isSearching ? self.searchResults.count : super.collectionView(collectionView, numberOfItemsInSection: section)
	}
	
	override func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
		if let cell  = cell as? CollectionViewCell {
			let entity = self.isSearching ? self.searchResults[indexPath.row] : self.assistant[indexPath]
			
			cell.titleLabel.text = entity?.fullName
			
			// Only load cached images; defer new downloads until scrolling ends
			if entity?.image == nil
			{
				if (self.collectionView!.isDragging == false && self.collectionView!.isDecelerating == false)
				{
					self.startIconDownload(entity!, for: indexPath)
				}
				
				// if a download is deferred or in progress, return a placeholder image
				cell.imageView?.image = UIImage(named: "Placeholder")
			}
			else
			{
				cell.imageView?.image = entity?.image
			}
			cell.imageView?.contentMode = .center
			
			
		}
	}

	// called by our ImageDownloader when an icon is ready to be displayed
	override func downloaded<T>(_ image: UIImage?, forEntity entity: T) {

		if isSearching {
			if let index = self.searchResults.firstIndex(of: entity as! Contact) {
				self.searchResults[index].image = image
				let indexPath = IndexPath(row: index, section: 0)
				if let cell = self.collectionView?.cellForItem(at: indexPath) {
					self.configure(cell, at: indexPath)
				}
			}
		}
		
		super.downloaded(image, forEntity: entity)
	}

}


extension SearchablePhoneBookCVC: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {
			if text.isEmpty {
				self.searchResults = self.assistant.getAllEntities(sortedBy: nil)
			}
			else {
				self.searchResults = self.assistant.filteredEntities(with: { $0.fullName.contains(text) })
			}
			self.collectionView?.reloadData()
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.isSearching = false
		(self.collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize.height = 40
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.isSearching = true
		(self.collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize.height = 0
	}
	
}
