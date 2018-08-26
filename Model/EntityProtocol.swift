//
//  EntityProtocol.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 3/31/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

public protocol EntityProtocol {
	
	var id: Int { get }

	init?(data: [String: Any])
	
	subscript (key: String) -> String? { get }
	
}

public protocol GEntityProtocol: EntityProtocol {


	mutating func update(with newFetechedEntity: Self)

}

struct Apple: GEntityProtocol {
	
	func update(with newFetechedEntity: Apple) {
		
	}
	
	var id: Int
	
	init?(data: [String : Any]) {
		id = 0
	}
	
	func update(with newFetechedEntity: EntityProtocol) {
		
	}
	
}

extension EntityProtocol {
	
	var hashValue: Int {
		return id.hashValue
	}
	
	subscript (key: String) -> String? {
		return nil
	}
	
	static func ==(left: Self, right: Self) -> Bool {
		return left.id == right.id
	}
		
}

