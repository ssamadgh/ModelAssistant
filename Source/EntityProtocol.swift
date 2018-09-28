/**
	EntityProtocol.swift
	ModelAssistant

	Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

import UIKit

/**
An abstract protocol used by objects inserted to model assistant.

Every object the going to be used by model assistant should adopt to this protocol.
*/
public protocol EntityProtocol {
	
	/**
	A value that is unique for each entity.
	
	This property is used by model assistant to distinguish unique entities. Use this property for returning one of entity properties that is unique for all fetched entities.
	*/
	var uniqueValue: Int { get }

//	init?(data: [String: Any])
	
	/**
	Returns a section name according to a given section key.
	
	This subscript is used by model assistant to get section name of entity by given section key.
	Note that if you set a section key for model assistant, you must return a string value for that key in this subscript. Return nil if you do not want to categorize your data in sections.
	
	- Parameter key: A given section key
	- Returns: The section name relates to a given section key
	*/
	subscript (key: String) -> String? { get }
	
	/**
	Entity updates itself by the given new entity.
	
	This method is used by model assistant, if it detect a new entity inserted with the same uniqueValue to an existing entity into model assistant. So model assistant updates existed entity by the new inserted entity. Use this method to determine which property should be update if a new same entity detected.
	
	By default this method does nothing
	
	- Parameter newFetechedEntity: The given new entity that is same as this entity.
	*/
	mutating func update(with newFetechedEntity: EntityProtocol)

	
}

public extension EntityProtocol {
	
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(uniqueValue)
	}
	
//	var hashValue: Int {
//		return uniqueValue.hashValue
//	}
	
	static func ==(left: Self, right: Self) -> Bool {
		return left.uniqueValue == right.uniqueValue
	}
		
}

