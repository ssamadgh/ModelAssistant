//
//  SectionedPhoneBookCVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

private let reuseIdentifier = "Cell"

class SectionedPhoneBookCVC: SimplePhoneBookCVC {
	
	override func viewDidLoad() {
		self.title = "Sectioned Phone Book"
		
		self.model.sectionKey = "firstName"
		self.isSectioned = true
		self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
		super.viewDidLoad()
		
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
		view.frame.size.height = 40
		
		view.backgroundColor = .yellow
		
		return view
	}
	

	
}
