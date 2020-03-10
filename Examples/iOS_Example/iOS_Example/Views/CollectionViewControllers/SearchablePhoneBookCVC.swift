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
	
	var searchAssistant: ModelAssistant<Contact>!

	let isSearching: Bool = false
	
	var searchController: UISearchController!

	var allEntities: [Contact] = []
	
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
	
	override func fetchEntities(completion: (() -> Void)? = nil) {
		super.fetchEntities {
			self.allEntities = self.assistant.getAllEntities(sortedBy: nil)
		}
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
		
		self.searchAssistant = ModelAssistant(collectionController: self, sectionKey: nil)
		self.searchAssistant.sortEntities = { $0.firstName < $1.firstName }
		self.searchAssistant.sortSections = { $0.name < $1.name }
		self.searchAssistant.fetch([]) {
			if self.isSearching {
				self.collectionView.reloadData()
			}
		}
		
	}
	
	// MARK: UICollectionViewDataSource

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionReusableView
		
		let section = isSearching ? self.searchAssistant[indexPath.section] : self.assistant[indexPath.section]
		
		headerView.titleLabel.text = section?.name
		
		return headerView
	}


	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.isSearching ? self.searchAssistant.numberOfSections : super.numberOfSections(in: collectionView)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of items
		return self.isSearching ? self.searchAssistant.numberOfEntites(at: section) : super.collectionView(collectionView, numberOfItemsInSection: section)
	}
	
	override func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
		if let cell  = cell as? CollectionViewCell {
			let entity = self.isSearching ? self.searchAssistant![indexPath] : self.assistant[indexPath]
			
			if entity == nil { return }

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
			let entity = entity as! Contact
			self.searchAssistant.update(entity, mutate: { (mutateContact) in
				mutateContact.image = image
			}, completion: nil)

		}
		
		super.downloaded(image, forEntity: entity)
	}

}


extension SearchablePhoneBookCVC: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		
		if let text = searchController.searchBar.text {
			if text.isEmpty {
//				let allEntities = self.assistant.getAllEntities(sortedBy: nil)
				
				self.assistant.formIntersection(allEntities, completion: nil)
			}
			else {
				let entities = self.allEntities.filter { $0.fullName.contains(text) }
				self.assistant.formIntersection(entities, completion: nil)
			}
		}
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//		self.isSearching = false
//		(self.collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize.height = 40
//		self.assistant.insert(allEntities, completion: nil)
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//		self.isSearching = true
//		(self.collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize.height = 0
//		self.assistant.remove(allEntities, completion: nil)
	}
	
}
