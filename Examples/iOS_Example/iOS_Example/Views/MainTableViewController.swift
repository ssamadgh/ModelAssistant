//
//  BasicTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private enum TableViews: Int {
	case simplePhoneBookTable, sortablePhoneBookTable, sectionedPhoneBookTable, SearchablePhoneBookTable, paginationPhoneBookTable
	
	static let allValues: [TableViews] = [simplePhoneBookTable, sortablePhoneBookTable, sectionedPhoneBookTable, SearchablePhoneBookTable, paginationPhoneBookTable]
	
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
			
		case .paginationPhoneBookTable:
			return "Pagination Phone Book TableView"
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
			
		case .paginationPhoneBookTable:
			return PaginationTableViewController()
			
		}
	}
}

private enum CollectionViews: Int {
	case SimplePhoneBookCollection, SectionedPhoneBookCollection, PaginationCollection
	
	static let allValues: [CollectionViews] = [SimplePhoneBookCollection, SectionedPhoneBookCollection, PaginationCollection]
	
	var stringValue: String {
		switch self {
		case .SimplePhoneBookCollection:
			return "Simple Phone Book CollectionView"
			
		case .SectionedPhoneBookCollection:
			return "Sectioned Phone Book CollectionView"
			
		case .PaginationCollection:
			return "Pagination Phone Book CollectionView"
		}
	}
	
	var viewController: UIViewController {
		switch self {
		case .SimplePhoneBookCollection:
			return SimplePhoneBookCVC()
			
		case .SectionedPhoneBookCollection:
			return SectionedPhoneBookCVC()
			
		case .PaginationCollection:
			return PaginationCollectionVC()
			
		}
	}
}

enum MainSections: Int {
	case tableViewControllers, collectionViewControllers
	
	static let allValues: [MainSections] = [tableViewControllers, collectionViewControllers]
	
	var stringValue: String {
		
		switch self {
		case .tableViewControllers:
			return "Table ViewControllers"
			
		case .collectionViewControllers:
			return "Collection ViewControllers"
			
		}
	}
	
	var numberOfRows: Int {
		
		switch self {
		case .tableViewControllers:
			return TableViews.allValues.count
			
		case .collectionViewControllers:
			return CollectionViews.allValues.count
			
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
		self.tableView.tableFooterView = UIView()
		self.tableView.backgroundColor = UIColor.groupTableViewBackground
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return MainSections.allValues.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return MainSections.allValues[section].stringValue
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return MainSections.allValues[section].numberOfRows
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.accessoryType = .disclosureIndicator
		
		// Configure the cell...
		switch indexPath.section {
		case MainSections.tableViewControllers.rawValue:
			cell.textLabel?.text = TableViews(rawValue: indexPath.row)?.stringValue
			
		case MainSections.collectionViewControllers.rawValue:
			cell.textLabel?.text = CollectionViews(rawValue: indexPath.row)?.stringValue
			
		default: break
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch indexPath.section {
		case MainSections.tableViewControllers.rawValue:
			if let vc = TableViews(rawValue: indexPath.row)?.viewController {
				self.show(vc, sender: nil)
			}
			
		case MainSections.collectionViewControllers.rawValue:
			if let vc = CollectionViews(rawValue: indexPath.row)?.viewController {
				self.show(vc, sender: nil)
			}
			
		default: break
		}
		
	}
	
	
}
