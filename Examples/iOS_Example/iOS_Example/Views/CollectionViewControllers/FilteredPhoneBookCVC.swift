//
//  FilteredPhoneBookCVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class FilteredPhoneBookCVC: SectionedPhoneBookCVC {

	override func viewDidLoad() {
		
		super.viewDidLoad()
		self.title = "Filtered Phone Book"
		
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: sectionKey)
		self.assistant.filter = { String(Array($0.firstName)[0]).uppercased() == "A" }
	}

}
