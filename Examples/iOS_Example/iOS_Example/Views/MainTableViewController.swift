//
//  BasicTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private enum TableViews: Int {
	case simplePhoneBookTable, sortablePhoneBookTable, sectionedPhoneBookTable, filteredPhoneBookTable, searchablePhoneBookTable, mutablePhoneBookTable, paginationPhoneBookTable, ModernPhoneBookTable
	
	static let allValues: [TableViews] = [simplePhoneBookTable, sortablePhoneBookTable, sectionedPhoneBookTable, filteredPhoneBookTable, searchablePhoneBookTable, mutablePhoneBookTable, paginationPhoneBookTable, ModernPhoneBookTable]
	
	var stringValue: String {
		let suffix = " Phone Book TableView"
		switch self {
		case .simplePhoneBookTable:
			return "Simple" + suffix
			
		case .sortablePhoneBookTable:
			return "Sortable" + suffix
			
		case .sectionedPhoneBookTable:
			return "Sectioned" + suffix
			
		case .filteredPhoneBookTable:
			return "Filtered" + suffix
			
		case .searchablePhoneBookTable:
			return "Searchable" + suffix
			
		case .mutablePhoneBookTable:
			return "Mutable" + suffix
			
		case .paginationPhoneBookTable:
			return "Pagination" + suffix
			
		case .ModernPhoneBookTable:
			return "Thread Safe" + suffix
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
			
		case .filteredPhoneBookTable:
			return FilteredPhoneBookTVC()
			
		case .searchablePhoneBookTable:
			return SearchablePhoneBookTVC()
			
		case .mutablePhoneBookTable:
			return MutablePhoneBookTVC()
			
		case .paginationPhoneBookTable:
			return PaginationPhoneBookTVC()
			
		case .ModernPhoneBookTable:
			return ThreadSafePhoneBookTVC()

		}
	}
	
}

private enum CollectionViews: Int {
	case simplePhoneBookCollection, sortablePhoneBookCollection, sectionedPhoneBookCollection, filteredPhoneBookCollection, searchablePhoneBookCollection, mutablePhoneBookCollection, paginationPhoneBookCollection
	
	static let allValues: [CollectionViews] = [simplePhoneBookCollection, sortablePhoneBookCollection, sectionedPhoneBookCollection, filteredPhoneBookCollection, mutablePhoneBookCollection, searchablePhoneBookCollection, paginationPhoneBookCollection]
	
	var stringValue: String {
		let suffix = " Phone Book CollectionView"

		switch self {
		case .simplePhoneBookCollection:
			return "Simple" + suffix
			
		case .sortablePhoneBookCollection:
			return "Sortable" + suffix
			
		case .sectionedPhoneBookCollection:
			return "Sectioned" + suffix
			
		case .filteredPhoneBookCollection:
			return "Filtered" + suffix

		case .searchablePhoneBookCollection:
			return "Searchable" + suffix

		case .mutablePhoneBookCollection:
			return "Mutable" + suffix

		case .paginationPhoneBookCollection:
			return "Pagination" + suffix
		}
	}
	
	var viewController: UIViewController {
		switch self {
		case .simplePhoneBookCollection:
			return SimplePhoneBookCVC()
			
		case .sortablePhoneBookCollection:
			return SortablePhoneBookCVC()
			
		case .sectionedPhoneBookCollection:
			return SectionedPhoneBookCVC()
			
		case .filteredPhoneBookCollection:
			return FilteredPhoneBookCVC()

		case .searchablePhoneBookCollection:
			return SearchablePhoneBookCVC()

		case .mutablePhoneBookCollection:
			return MutablePhoneBookCVC()

		case .paginationPhoneBookCollection:
			return PaginationPhoneBookCVC()
			
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
