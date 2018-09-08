//
//  FilemanagerService.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import Model

class JsonService {
	
	class func getEntities<Entity: EntityProtocol & Hashable & Decodable>(fromFile fileName: String) -> [Entity] {
		let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
		let json = try! Data(contentsOf: url)
		
		let decoder = JSONDecoder()
		let entities = try! decoder.decode([Entity].self, from: json)
		return entities
	}
}
