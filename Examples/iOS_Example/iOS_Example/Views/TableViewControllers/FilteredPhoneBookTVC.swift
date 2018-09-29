//
//  FilteredPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:
	You can set a filter on assistant to fetch just some specific of entities.
*/

import UIKit

class FilteredPhoneBookTVC: SectionedPhoneBookTVC {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		self.title = "Filtered Phone Book"
		self.navigationItem.rightBarButtonItem = nil

	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: sectionKey)
		
		//Set a filter on model assistant to fetch just some specific of entities.
		self.assistant.filter = { String(Array($0.firstName)[0]).uppercased() == "A" }
	}

}
