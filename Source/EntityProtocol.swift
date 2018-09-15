//
//  EntityProtocol.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 3/31/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

public protocol EntityProtocol {
	
	var uniqueValue: Int { get }

//	init?(data: [String: Any])
	
	subscript (key: String) -> String? { get }
	
	mutating func update(with newFetechedEntity: EntityProtocol)

	
}

public extension EntityProtocol {
	
	var hashValue: Int {
		return uniqueValue.hashValue
	}
	
	static func ==(left: Self, right: Self) -> Bool {
		return left.uniqueValue == right.uniqueValue
	}
		
}

