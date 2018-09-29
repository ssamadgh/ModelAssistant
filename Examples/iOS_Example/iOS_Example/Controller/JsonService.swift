//
//  FilemanagerService.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import ModelAssistant

class JsonService {
	
	static var documentURL: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}()
	
	class func getEntities<Entity: MAEntity & Hashable & Decodable>(fromURL url: URL) -> [Entity] {
//		let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
		let json = try! Data(contentsOf: url)
		
		let decoder = JSONDecoder()
		let entities = try! decoder.decode([Entity].self, from: json)
		return entities
	}
	
	class func saveEntities<Entity: MAEntity & Hashable & Encodable>(_ entities: [Entity], toURL url: URL, finished: (() -> Void)?) {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		let data = try! encoder.encode(entities)
		
//		let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
		FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
		print("Saved in ", url.path)
		finished?()
	}
	
}
