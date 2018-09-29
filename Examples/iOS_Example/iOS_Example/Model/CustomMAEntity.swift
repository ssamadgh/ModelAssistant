//
//  CustomMAEntity.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

// Abstract: In this file we created a protocol which is inherit MAEntity protocol.
// This way you can make a custom protocol for your project and adopt your model objects to it.

import Foundation
import ModelAssistant


protocol CustomMAEntity: MAEntity {
	
	init?(data: [String : Any])
}
