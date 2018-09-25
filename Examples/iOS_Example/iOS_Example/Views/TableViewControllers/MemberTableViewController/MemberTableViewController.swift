//
//  TestTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Model

class MemberTableViewController: UITableViewController {
	
	var model: Model<Member>!
	var manager: ModelDelegateManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "insert", style: .plain, target: self, action: #selector(insert(_:)))
		
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		self.configureModel(sectionKey: nil)
		self.fetchEntities()

    }
	
	@objc func insert(_ sender: UIBarButtonItem) {
		let url = Bundle.main.url(forResource: "MOCK_DATA_20", withExtension: "json")!
		let members: [Member] = JsonService.getEntities(fromURL: url)

		self.model.insert(members, completion: nil)
	}
	
	func configureModel(sectionKey: String?) {
		self.model = Model<Member>(sectionKey: "country")
		self.model.sortSections = { $0.name < $1.name }
		self.model.sortEntities = { $0.firstName < $1.firstName }

		self.manager = ModelDelegateManager(controller: self)
		self.model.delegate = self.manager

	}
	
	func fetchEntities() {

		let url = Bundle.main.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		let members: [Member] = JsonService.getEntities(fromURL: url)
		self.model.fetch(members) {
			self.tableView.reloadData()
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.model[section]
		return section?.name
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return self.model.numberOfSections
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.model.numberOfEntites(at: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		self.configure(cell, at: indexPath)
		
		return cell
	}
	
	override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
		let entity = self.model[indexPath]
		cell.textLabel?.text = entity?.fullName
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return self.model.sectionIndexTitles
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return self.model.section(forSectionIndexTitle: title, at: index)
	}



}
