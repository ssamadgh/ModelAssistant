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

	var imageDownloadsInProgress: [Int : ImageDownloader]!  // the set of IconDownloader objects for each app
	
	var model = Model<Contact>()
	var manager: ModelDelegateManager!
	var isSectioned: Bool = false
	var insertingNewEntities = false
	var resourceFileName: String = "PhoneBook"
	
	init() {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 1
		layout.minimumLineSpacing = layout.minimumInteritemSpacing
		let screenWidth = UIScreen.main.bounds.width
		let itemWidth = screenWidth/3 - layout.minimumInteritemSpacing
		layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
		super.init(collectionViewLayout: layout)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.imageDownloadsInProgress = [:]
		
		self.title = " Phone Book CollectionView"
		
		let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonAction(_:)))
		
		let sortButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortBarButtonAction(_:)))
		
		self.navigationItem.rightBarButtonItems = [addButtonItem, self.editButtonItem, sortButtonItem]

		self.collectionView?.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
		self.configureModel()

    }
	
	func configureModel() {
		let url = Bundle.main.url(forResource: resourceFileName, withExtension: "json")!
		let json = try! Data(contentsOf: url)
		
		let decoder = JSONDecoder()
		let members = try! decoder.decode([Contact].self, from: json)
		self.manager = ModelDelegateManager(controller: self)
		self.model.delegate = self.manager

		self.model.fetch(members) {
			DispatchQueue.main.async {
				self.collectionView?.reloadData()
			}
		}
	}
	
	@objc func addBarButtonAction(_ sender: UIBarButtonItem) {
		self.contactDetailsAlertController(for: nil)
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

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
	
	//MARK: - Table cell image support
	func startIconDownload(_ entity: Contact, for indexPath: IndexPath) {
		let uniqueValue = entity.uniqueValue
		var imageDownloader: ImageDownloader! = imageDownloadsInProgress[uniqueValue]
		if imageDownloader == nil {
			imageDownloader = ImageDownloader()
			imageDownloader.entity = entity
			imageDownloader.delegate = self
			imageDownloadsInProgress[uniqueValue] = imageDownloader
			imageDownloader.startDownload()
		}
	}
	
	// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
	func loadImagesForOnscreenRows() {
		if self.model.numberOfFetchedEntities > 0 {
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
	func imageDidLoad(for entity: CustomEntityProtocol) {
		
		self.model.update(at: self.model.indexPath(of: entity as! Contact)!, mutate: { (contact) in
			contact.image = entity.image
		})
		
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
	
	func contactDetailsAlertController(for contact: Contact?) {
		
		var firstNameTextField: UITextField!
		var lastNameTextField: UITextField!
		var phoneTextField: UITextField!
		
		let alertController = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
		alertController.addTextField { (textField) in
			firstNameTextField = textField
			firstNameTextField.placeholder = "First Name"
			firstNameTextField.text = contact?.firstName
			
		}
		
		alertController.addTextField { (textField) in
			lastNameTextField = textField
			lastNameTextField.placeholder = "Last Name"
			lastNameTextField.text = contact?.lastName
		}
		
		alertController.addTextField { (textField) in
			phoneTextField = textField
			phoneTextField.placeholder = "Phone Number"
			phoneTextField.text = contact?.phone
			phoneTextField.keyboardType = .phonePad
		}
		
		let doneButtonTitle = contact == nil ? "Add" : "Update"
		alertController.addAction(UIAlertAction(title: doneButtonTitle, style: .default, handler: { (action) in
			if contact != nil {
				let indexPath = self.model.indexPath(of: contact!)!
				let firstName = firstNameTextField.text!
				let lastName = lastNameTextField.text!
				let phone = phoneTextField.text!
				
				self.model.update(at: indexPath, mutate: { (contact) in
					contact.firstName = firstName
					contact.lastName = lastName
					contact.phone = phone
				}, finished: {
					if let indexPath = self.collectionView?.indexPathsForSelectedItems?.first {
						self.collectionView?.deselectItem(at: indexPath, animated: true)
					}
				})
			}
			else {
				let dic = ["id" : 0]
				var contact = Contact(data: dic)!
				contact.firstName = firstNameTextField.text!
				contact.lastName = lastNameTextField.text!
				contact.phone = phoneTextField.text!
				
				//				self.model.insertAtFirst(contact, applySort: false)
				self.model.insert([contact])
			}
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			
			if let indexPath = self.collectionView?.indexPathsForSelectedItems?.first {
				self.collectionView?.deselectItem(at: indexPath, animated: true)
			}
			
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
	@objc func sortBarButtonAction(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
		
		if isSectioned {
			alertController.addAction(UIAlertAction(title: "Section A-Z", style: .default, handler: { (action) in
				self.model.sortSections(by: { $0.name < $1.name }, finished: nil)
			}))
			
			alertController.addAction(UIAlertAction(title: "Section Z-A", style: .default, handler: { (action) in
				self.model.sortSections(by: { $0.name < $1.name }, finished: nil)
			}))
		}
		
		alertController.addAction(UIAlertAction(title: "First Name A-Z", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.firstName < $1.firstName }
			self.model.reorder(finished: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name Z-A", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.firstName > $1.firstName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name A-Z", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.lastName < $1.lastName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name Z-A", style: .default, handler: { (action) in
			self.model.sortEntities = { $0.lastName > $1.lastName }
			self.model.reorder(finished: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			//...
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}


}
