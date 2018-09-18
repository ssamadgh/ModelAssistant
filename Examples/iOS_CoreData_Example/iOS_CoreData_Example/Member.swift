//
//  Member.swift
//  iOS_CoreData_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import Model

struct Member: EntityProtocol & Hashable, Codable {
	
	
	var uniqueValue: Int {
		return Int(phone)!
	}
	
	let id: Int
	var firstName: String
	var lastName: String
	var phone: String
	var imageURLString: String?
	var image: UIImage?
	var imageURL: URL {
		let string = imageURLString ?? "https://robohash.org/\(firstName)\(lastName)\(id).jpg?size=30x30&set=set1"
		return URL(string: string)!
	}
	
	var fullName: String {
		return firstName + " " + lastName
	}
	
	/*
	{"id":1,"firstName":"Corenda","lastName":"Nissle","email":"cnissle0@hostgator.com","gender":"Female","phone":"1277173425","avatar":"https://robohash.org/molestiaeteneturplaceat.jpg?size=100x100&set=set1"}
	*/
	
	init?(data: [String : Any]) {
		self.id = data["id"] as! Int
		self.firstName = data["firstName"] as? String ?? ""
		self.lastName = data["lastName"] as? String ?? ""
		self.phone = data["phone"] as? String ?? ""
		self.imageURLString = data["avatar"] as? String
	}
	
	mutating func update(with newFetechedEntity: EntityProtocol) {
		let entity = newFetechedEntity as! Member
		self.firstName = entity.firstName
		self.lastName = entity.lastName
	}
	
	subscript(key: String) -> String? {
		if key == "firstName" {
			return String(Array(self.firstName)[0]).uppercased()
		}
		
		if key == "lastName" {
			return String(Array(self.firstName)[0]).uppercased()
		}
		
		return nil
	}
	
	enum CodingKeys: String, CodingKey {
		case id, firstName, lastName, phone
		case imageURLString = "avatar"
	}
	
}
