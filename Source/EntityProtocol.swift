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

	init?(data: [String: Any])
	
	subscript (key: String) -> String? { get }
	
}

public protocol GEntityProtocol: EntityProtocol {


	mutating func update(with newFetechedEntity: Self)

}

public extension GEntityProtocol {
	
	var hashValue: Int {
		return uniqueValue.hashValue
	}
	
	subscript (key: String) -> String? {
		return nil
	}
	
	static func ==(left: Self, right: Self) -> Bool {
		return left.uniqueValue == right.uniqueValue
	}
		
}

