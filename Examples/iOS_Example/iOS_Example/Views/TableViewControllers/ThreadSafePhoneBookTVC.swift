//
//  ModernPhoneBookTVC.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:

	With model assistant you can call its methods in multiple threads concurrently without worry about race condition or crashing tableView
*/


import UIKit
import ModelAssistant

class ThreadSafePhoneBookTVC: BasicTableViewController {
	
	private let dispatchQueue = DispatchQueue(label: "com.ThreadSafePhoneBookTVC.ConcirrentGCD.DispatchQueue", attributes: DispatchQueue.Attributes.concurrent)
	
	var manager: ModelAssistantDelegateManager!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Thread Safe Phone Book"
		
		let doMagicButtonItem = UIBarButtonItem(title: "Do Concurrent!", style: .plain, target: self, action: #selector(doMagicBarButtonAction(_:)))
		
		self.navigationItem.rightBarButtonItems = [doMagicButtonItem]
		
	}
	
	override func configureModelAssistant(sectionKey: String?) {
		super.configureModelAssistant(sectionKey: sectionKey)
		self.manager = ModelAssistantDelegateManager(controller: self)
		self.assistant.delegate = self.manager
	}
	
	@objc func doMagicBarButtonAction(_ sender: UIBarButtonItem) {
		
		let firstIndexPath = IndexPath(row: 0, section: 0)
		
		let dic = ["id" : 0]
		var contact = Contact(data: dic)!
		contact.firstName = "Samad"
		contact.lastName = "Khatar"
		contact.phone = "9934243243"
		
		
		// We do some interaction with model assistant concurrently.
		
		self.dispatchQueue.async {
			
			self.assistant.insert(contact, at: firstIndexPath, completion: nil)
		}
		
		self.dispatchQueue.async {
			contact.firstName = "Abbas"
			contact.phone = "9342432432"
			self.assistant.insert(contact, at: firstIndexPath, completion: nil)
		}
		
		self.dispatchQueue.async {
			self.assistant.remove(at: IndexPath(row: 2, section: 0), completion: nil)
		}
		
		self.dispatchQueue.async {
			self.assistant.update(at: IndexPath(row: 3, section: 0), mutate:  { (contact) in
				contact.firstName = "Joooooojoooo"
				contact.lastName = "Talaaaaaaaieeeee"
			}, completion: nil)
		}
		
	}
	
}

