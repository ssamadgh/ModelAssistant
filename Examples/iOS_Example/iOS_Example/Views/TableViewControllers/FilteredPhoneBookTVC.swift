//
//  FilteredPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class FilteredPhoneBookTVC: SectionedPhoneBookTVC {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		self.title = "Filtered Phone Book"
		
	}
	
	override func configureModel() {
		self.model.filter = { String(Array($0.firstName)[0]).uppercased() == "A" }
		super.configureModel()
	}

}
