//
//  ContactEntity+CoreDataProperties.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/15/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//
//

import Foundation
import CoreData
import ModelAssistant

extension ContactEntity: MAEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactEntity> {
        return NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
    }

    @NSManaged public var displayOrder: Int64
    @NSManaged public var firstName: String
    @NSManaged public var id: Int32
    @NSManaged public var imageURLString: String?
    @NSManaged public var lastName: String
    @NSManaged public var phone: String?
	
	var imageURL: URL {
		let string = imageURLString ?? "https://robohash.org/\(firstName)\(lastName)\(id).jpg?size=30x30&set=set1"
		return URL(string: string)!
	}

	var fullName: String {
		return firstName + " " + lastName
	}
	
	public var uniqueValue: Int {
		return Int(self.phone ?? "0")!
	}
	
	@objc public var index: String? {
		return String(Array(self.firstName)[0]).uppercased()
	}
	
	public subscript(key: String) -> String? {
		if key == "firstName" {
			return String(Array(self.firstName)[0]).uppercased()
		}
		
		if key == "lastName" {
			return String(Array(self.firstName)[0]).uppercased()
		}
		
		return nil
	}

	public func update(with newFetechedEntity: MAEntity) {
		let entity = newFetechedEntity as! ContactEntity
		self.firstName = entity.firstName
		self.lastName = entity.lastName

	}
		
}
