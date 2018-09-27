//
//  SectionedPhoneBookCVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import ModelAssistant

private let reuseIdentifier = "Cell"

class SectionedPhoneBookCVC: SortablePhoneBookCVC {
	
	override init() {
		super.init()
		(self.collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize.height = 40
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		
		self.collectionView?.register(UINib(nibName: "CollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")

		super.viewDidLoad()
		self.title = "Sectioned Phone Book"

	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: "firstName")
		self.assistant.sortSections = { $0.name < $1.name }
	}

	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionReusableView
		
		let section = self.assistant[indexPath.section]

		headerView.titleLabel.text = section?.name
		
		return headerView
	}
	
	override func sortBarButtonAction(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
		
		alertController.addAction(UIAlertAction(title: "Section A-Z", style: .default, handler: { (action) in

			self.assistant.sortSections(by: { $0.name < $1.name }, completion: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "Section Z-A", style: .default, handler: { (action) in
			self.assistant.sortSections(by: { $0.name > $1.name }, completion: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name A-Z", style: .default, handler: { (action) in
			self.assistant.sortEntities = { $0.firstName < $1.firstName }

			self.assistant.reorderEntities(completion: nil)
		}))
		
		alertController.addAction(UIAlertAction(title: "First Name Z-A", style: .default, handler: { (action) in
			self.assistant.sortEntities = { $0.firstName > $1.firstName }

			self.assistant.reorderEntities(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name A-Z", style: .default, handler: { (action) in
			self.assistant.sortEntities = { $0.lastName < $1.lastName }

			self.assistant.reorderEntities(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Last Name Z-A", style: .default, handler: { (action) in
			self.assistant.sortEntities = { $0.lastName > $1.lastName }

			self.assistant.reorderEntities(completion: nil)
			
		}))
		
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			//...
		}))
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
}
