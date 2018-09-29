//
//  IndexPath+Extensions.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 3/31/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

extension IndexPath: Strideable {
	public typealias Stride = Int

	public func distance(to other: IndexPath) -> Int {
		return self.row.distance(to: other.row)
	}

	public func advanced(by n: Int) -> IndexPath {
		let row = self.row.advanced(by: n)
		return IndexPath(row: row, section: self.section)
	}

	static func indexPaths(in range: CountableClosedRange<Int>, atSection section: Int) -> [IndexPath] {
		let lowerIndexPath = IndexPath(row: range.lowerBound, section: section)
		let upperIndexPth = IndexPath(row: range.upperBound, section: section)

		let indexPaths: [IndexPath] = Array(lowerIndexPath...upperIndexPth)
		return indexPaths
	}
}
