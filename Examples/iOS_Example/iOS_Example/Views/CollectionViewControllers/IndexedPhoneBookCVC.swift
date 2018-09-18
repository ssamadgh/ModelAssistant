//
//  IndexedPhoneBookCVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class IndexedPhoneBookCVC: SectionedPhoneBookCVC {

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Indexed Phone Book"
		self.navigationItem.rightBarButtonItem = nil
	}

	
	override func indexTitles(for collectionView: UICollectionView) -> [String]? {
		return self.model.sectionIndexTitles
	}
	
	override func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
		
		let section = self.model.section(forSectionIndexTitle: title, at: index)
		
		return IndexPath(item: 0, section: section)
	}


}
