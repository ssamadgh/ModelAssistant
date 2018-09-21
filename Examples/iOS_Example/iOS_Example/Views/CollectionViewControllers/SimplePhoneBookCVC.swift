//
//  CollectionViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

private let reuseIdentifier = "Cell"

class SimplePhoneBookCVC: UICollectionViewController, ImageDownloaderDelegate {

	var imageDownloadsInProgress: [Int : ImageDownloader<Contact>]!  // the set of IconDownloader objects for each app
	
	var model: Model<Contact>!

	var manager: ModelDelegateManager!
	var resourceFileName: String = "PhoneBook"
	
	init() {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 1
		layout.minimumLineSpacing = layout.minimumInteritemSpacing
		let screenWidth = UIScreen.main.bounds.width
		let itemWidth = screenWidth/3 - layout.minimumInteritemSpacing
		layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
		super.init(collectionViewLayout: layout)
		self.collectionView?.backgroundColor = UIColor(red: 118/255, green: 214/255, blue: 255/255, alpha: 1)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.imageDownloadsInProgress = [:]
		
		self.title = "Simple Phone Book"
		
		self.collectionView?.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

		self.configureModel(sectionKey: nil)
		self.fetchEntities()
    }
	
	func configureModel(sectionKey: String?) {
		self.model = Model<Contact>(sectionKey: sectionKey)
		self.manager = ModelDelegateManager(controller: self)
		self.model.delegate = self.manager

	}

	func fetchEntities() {
		let url = Bundle.main.url(forResource: resourceFileName, withExtension: "json")!
		let members: [Contact] = JsonService.getEntities(fromURL: url)
		
		self.model.fetch(members) {
			DispatchQueue.main.async {
				self.collectionView?.reloadData()
			}
		}
	}

	// MARK: UICollectionViewDataSource


	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.model.numberOfSections
	}

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.model.numberOfEntites(at: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        // Configure the cell
		self.configure(cell, at: indexPath)
    
        return cell
    }
	
	override func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
		if let cell  = cell as? CollectionViewCell {
			let entity = self.model[indexPath]
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
	
	//MARK: - Table cell image support
	func startIconDownload(_ entity: Contact, for indexPath: IndexPath) {
		let uniqueValue = entity.uniqueValue
		var imageDownloader: ImageDownloader! = imageDownloadsInProgress[uniqueValue]
		if imageDownloader == nil {
			imageDownloader = ImageDownloader(from: entity.imageURL, forEntity: entity)
			imageDownloader.delegate = self
			imageDownloadsInProgress[uniqueValue] = imageDownloader
			imageDownloader.startDownload()
		}
	}
	
	// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
	func loadImagesForOnscreenRows() {
		if !self.model.isEmpty {
			let visiblePaths = self.collectionView?.indexPathsForVisibleItems ?? []
			for indexPath in visiblePaths {
				let entity = self.model[indexPath]
				if entity?.image == nil // avoid the app icon download if the app already has an icon
				{
					self.startIconDownload(entity!, for: indexPath)
				}
			}
		}
	}
	
	// called by our ImageDownloader when an icon is ready to be displayed
	func downloaded<T>(_ image: UIImage?, forEntity entity: T) {
		let entity = entity as! Contact
		let indexPath = self.model.indexPath(of: entity)!
		self.model.update(at: indexPath, mutate: { (contact) in
			contact.image = image
		}, completion: nil)
		
		// Remove the IconDownloader from the in progress list.
		// This will result in it being deallocated.
		self.imageDownloadsInProgress.removeValue(forKey: entity.uniqueValue)
	}
	
	//MARK: - Deferred image loading (UIScrollViewDelegate)
	
	
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			self.loadImagesForOnscreenRows()
			
		}
	}
	
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.loadImagesForOnscreenRows()		
	}

}
