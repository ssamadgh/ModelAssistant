//
//  Array+Extensions.swift
//  ModelAssistant iOS
//
//  Created by Seyed Samad Gholamzadeh on 10/28/18.
//

import Foundation

extension Array where Element: Hashable {
	
	
	func removingDuplicates() -> [Element] {
		var addedDict = [Element: Bool]()
		
		return filter {
			addedDict.updateValue(true, forKey: $0) == nil
		}
	}
	
	mutating func removeDuplicates() {
		self = self.removingDuplicates()
	}
	
}
