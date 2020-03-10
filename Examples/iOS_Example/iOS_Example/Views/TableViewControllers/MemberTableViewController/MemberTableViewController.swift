//
//  TestTableViewController.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import ModelAssistant

class MemberTableViewController: UITableViewController {
	
	var assistant: ModelAssistant<Member>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "insert", style: .plain, target: self, action: #selector(insert(_:)))
		
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		self.configureModelAssistant(sectionKey: nil)
		self.fetchEntities()

    }
	
	@objc func insert(_ sender: UIBarButtonItem) {
		let url = Bundle.main.url(forResource: "MOCK_DATA_20", withExtension: "json")!
		let members: [Member] = JsonService.getEntities(fromURL: url)

		self.assistant.insert(members, completion: nil)
	}
	
	func configureModelAssistant(sectionKey: String?) {
		self.assistant = ModelAssistant<Member>(collectionController: self, sectionKey: "country")
		self.assistant.sortSections = { $0.name < $1.name }
		self.assistant.sortEntities = { $0.firstName < $1.firstName }
	}
	
	func fetchEntities() {

		let url = Bundle.main.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		let members: [Member] = JsonService.getEntities(fromURL: url)
		self.assistant.fetch(members) {
			self.tableView.reloadData()
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.assistant[section]
		return section?.name
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return self.assistant.numberOfSections
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.assistant.numberOfEntites(at: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		self.configure(cell, at: indexPath)
		
		return cell
	}
	
	func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
		let entity = self.assistant[indexPath]
		cell.textLabel?.text = entity?.fullName
	}
	
	override func update(_ cell: UITableViewCell, at indexPath: IndexPath) {
		self.configure(cell, at: indexPath)
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return self.assistant.sectionIndexTitles
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return self.assistant.section(forSectionIndexTitle: title, at: index)
	}



}
