//
//  BasicTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

enum MainTVCData: Int {
	case simplePhoneBookTable, sortablePhoneBookTable, sectionedPhoneBookTable, SearchablePhoneBookTable, paginationTVC, SimplePhoneBookCollectionVC, SectionedPhoneBookCollectionVC, PaginationCVC
	
	static let allValues: [MainTVCData] = [simplePhoneBookTable, sortablePhoneBookTable, sectionedPhoneBookTable, SearchablePhoneBookTable, paginationTVC, SimplePhoneBookCollectionVC, SectionedPhoneBookCollectionVC, PaginationCVC]
	
	var stringValue: String {
		switch self {
		case .simplePhoneBookTable:
			return "Simple Phone Book TableView"
		
		case .sortablePhoneBookTable:
			return "Sortable Phone Book TableView"

		case .sectionedPhoneBookTable:
			return "Sectioned Phone Book TableView"
			
		case .SearchablePhoneBookTable:
			return "Searchable Phone Book TableView"
			
		case .paginationTVC:
			return "Pagination Phone Book TableView"
			
		case .SimplePhoneBookCollectionVC:
			return "Simple Phone Book CollectionView"
			
		case .SectionedPhoneBookCollectionVC:
			return "Sectioned Phone Book CollectionView"
			
		case .PaginationCVC:
			return "Pagination Phone Book CollectionView"
		}
	}
	
	var viewController: UIViewController {
		switch self {
		case .simplePhoneBookTable:
			return SimplePhoneBookTVC()
			
		case .sortablePhoneBookTable:
			return SortablePhoneBookTVC()

		case .sectionedPhoneBookTable:
			return SectionedPhoneBookTVC()
			
		case .SearchablePhoneBookTable:
			return SearchablePhoneBookTVC()
			
		case .paginationTVC:
			return PaginationTableViewController()
			
		case .SimplePhoneBookCollectionVC:
			return SimplePhoneBookCVC()
			
		case .SectionedPhoneBookCollectionVC:
			return SectionedPhoneBookCVC()
			
		case .PaginationCVC:
			return PaginationCollectionVC()
			
		}
	}
}

class MainTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backBarButton
		
		self.title = "variety uses of Model"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MainTVCData.allValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
		cell.textLabel?.text = MainTVCData(rawValue: indexPath.row)?.stringValue
		cell.accessoryType = .disclosureIndicator
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let vc = MainTVCData(rawValue: indexPath.row)?.viewController {
			self.show(vc, sender: nil)
		}
	}


}
