//
//  MAFaultable.swift
//  ModelAssistant iOS
//
//  Created by Seyed Samad Gholamzadeh on 11/19/18.
//

import Foundation
import UIKit

public protocol MAFaultable {
	
	var isFoult: Bool { get set }
	mutating func fault()
	mutating func fire()
}
