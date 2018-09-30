//
//  member.swift
//  MyModelLibrary
//
//  Created by Seyed Samad Gholamzadeh on 8/23/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import ModelAssistant

struct Member: MAEntity, Hashable, Codable {


	var uniqueValue: Int {
		return id
	}

	var id: Int
	var firstName: String
	var lastName: String
	var fullName: String {
		return firstName + " " + lastName
	}
	var email: String
	var gender: String
	var country: String

	init?(data: [String : Any]) {
		self.id = data["id"] as! Int
		self.firstName = data["first_name"] as? String ?? ""
		self.lastName = data["last_name"] as? String ?? ""
		self.email = data["email"] as? String ?? ""
		self.gender = data["gender"] as? String ?? ""
		self.country = data["country"] as? String ?? ""
	}

	mutating func update(with newFetechedEntity: MAEntity) {
		let entity = newFetechedEntity as! Member
		self.firstName = entity.firstName
		self.lastName = entity.lastName
		self.email = entity.email
		self.country = entity.country
	}

	subscript(key: String) -> String? {

		if key == "country" {
			return self.country
		}

		return nil
	}

	enum CodingKeys: String, CodingKey {
		case firstName = "first_name"
		case lastName = "last_name"
		case id, email, gender, country
	}

	static func ==(left: Member, right: Member) -> Bool {
		return left.id == right.id && left.fullName == right.fullName
//		return left.id == right.id
	}

	/*
	{"id":1,"first_name":"Orland","last_name":"Stapleford","email":"ostapleford0@bluehost.com","gender":"Male","country":"Indonesia"}
	*/

}
