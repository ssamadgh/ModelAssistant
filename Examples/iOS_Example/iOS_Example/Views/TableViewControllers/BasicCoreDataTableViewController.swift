//
//  CoreDataTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/15/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model
import CoreData

class BasicCoreDataTableViewController: UITableViewController, ImageDownloaderDelegate {
	
	typealias ModelAlias = CoreDataModel
	typealias EntityAlias = ContactEntity
	
	var imageDownloadsInProgress: [Int : ImageDownloader<EntityAlias>]!  // the set of IconDownloader objects for each app
	
	var model: ModelAlias<EntityAlias>!
	var resourceFileName: String = "PhoneBook"
	
	var manager: ModelDelegateManager!

	var context: NSManagedObjectContext!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.imageDownloadsInProgress = [:]
		
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		self.configureModel()
	}
	
	func configureModel(for model: CoreDataModel<ContactEntity>) {
		
	}
	
	func configureModel() {
		let url = Bundle.main.url(forResource: resourceFileName, withExtension: "json")!
		let fetchedMembers: [Contact] = JsonService.getEntities(fromURL: url)
		
		let container = (UIApplication.shared.delegate as! AppDelegate).coreDataController.container
		let context = container.viewContext
		self.context = context
		
		let displayOrderSort = NSSortDescriptor(key: "displayOrder", ascending: true)
//		let index = NSSortDescriptor(key: "index", ascending: true)
		let firstNameSort = NSSortDescriptor(key: "firstName", ascending: true)

		let model: Any
		
		if ModelAlias<EntityAlias>.self == CoreDataModel<ContactEntity>.self {
			model = CoreDataModel<ContactEntity>(context: context, sortDescriptors: [firstNameSort, displayOrderSort], predicate: nil, sectionKey: "index", cacheName: nil)
		}
		else {
			model = Model<Contact>(sectionKey: nil)
		}
		
		self.model = (model as! ModelAlias<EntityAlias>)
		
		self.manager = ModelDelegateManager(controller: self)
		self.model.delegate = self.manager

		
		var members: [EntityAlias] = []
		
		if EntityAlias.self == ContactEntity.self {
			if !isFetchedCoreData {
				var anyMembers: [Any] = []
				for member in fetchedMembers {
					let memberEnttiy = ContactEntity(context: context)
					memberEnttiy.id = Int32(member.id)
					memberEnttiy.firstName = member.firstName
					memberEnttiy.lastName = member.lastName
					memberEnttiy.phone = member.phone
					memberEnttiy.imageURLString = member.imageURLString
					anyMembers.append(memberEnttiy)
				}
				
				members = anyMembers as! [EntityAlias]

				self.isFetchedCoreData = true
			}
		}
		else {
			let anyMembers: [Any] = fetchedMembers
			members = anyMembers as! [EntityAlias]
		}

		
		self.model.fetch(members) {
			self.tableView.reloadData()
		}
		
	}

	var isFetchedCoreData: Bool {
		
		get {
			return UserDefaults.standard.bool(forKey: "isFetchedCoreData")
		}
		
		set {
			UserDefaults.standard.set(newValue, forKey: "isFetchedCoreData")
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return self.model.numberOfSections
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.model.numberOfEntites(at: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		self.configure(cell, at: indexPath)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.model[section]
		return section?.name
	}

	override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
		
		let entity = self.model[indexPath]
		// Configure the cell...
		cell.textLabel?.text =  entity?.fullName
		
		// Only load cached images; defer new downloads until scrolling ends
		if entity?.image == nil
		{
			if (self.tableView.isDragging == false && self.tableView.isDecelerating == false)
			{
				self.startIconDownload(entity!)
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
	
	
	
	//MARK: - Table cell image support
	
	func startIconDownload(_ entity: EntityAlias) {
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
			let visiblePaths = self.tableView.indexPathsForVisibleRows ?? []
			for indexPath in visiblePaths {
				guard let entity = self.model[indexPath] else { return }
				if entity.image == nil // avoid the app icon download if the app already has an icon
				{
					self.startIconDownload(entity)
				}
			}
		}
	}
	
	// called by our ImageDownloader when an icon is ready to be displayed
	
	
	func downloaded<T>(_ image: UIImage?, forEntity entity: T) {
		let entity = entity as! EntityAlias
		self.model.update(entity, mutate: { (contact) in
			contact.image = image
			
		}, completion: {
			if ModelAlias<EntityAlias>.self == CoreDataModel<ContactEntity>.self {
				if let indexPath = self.model.indexPath(of: entity),
					let cell = self.tableView.cellForRow(at: indexPath) {
					self.configure(cell, at: indexPath)
				}
			}

		})
		
		// Remove the IconDownloader from the in progress list.
		// This will result in it being deallocated.
		
		let uniqueValue = entity.uniqueValue
		self.imageDownloadsInProgress.removeValue(forKey: uniqueValue)

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
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return  nil
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return 0
	}
	
}
