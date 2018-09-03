//
//  Contact.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Model

struct Contact: GEntityProtocol & Hashable, Codable {
	
	let id: Int
	var firstName: String
	var lastName: String
	var phone: String
	var avatarString: String?
	var avatarURL: URL {
		let string = avatarString ?? "https://robohash.org/\(firstName)\(lastName)\(id).jpg?size=30x30&set=set1"
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
		self.avatarString = data["avatar"] as? String
	}
	
	mutating func update(with newFetechedEntity: Contact) {
		self.firstName = newFetechedEntity.firstName
		self.lastName = newFetechedEntity.lastName
		self.phone = newFetechedEntity.phone
	}

	subscript(key: String) -> String? {
		if key == "firstName" {
			return String(Array(self.firstName)[0])
		}
		
		if key == "lastName" {
			return String(Array(self.firstName)[0])
		}

		return nil
	}
	
	enum CodingKeys: String, CodingKey {
		case id, firstName, lastName, phone
		case avatarString = "avatar"
	}
	
}
