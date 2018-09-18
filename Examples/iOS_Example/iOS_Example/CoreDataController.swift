//
//  CoreDataController.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 11/27/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreData


class CoreDataController {
		
	var container: NSPersistentContainer
	
	init(completionClosure: @escaping () -> ()) {
		container = NSPersistentContainer(name: "ContactDataModel")
		print(NSPersistentContainer.defaultDirectoryURL())
		container.loadPersistentStores() { (description, error) in
			if let error = error {
				fatalError("Failed to load Core Data stack: \(error)")
			}
			completionClosure()
		}
	}
	
}


