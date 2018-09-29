//
//  CustomMAEntity.swift
//  iOS_Example
//
//  Created by Seyed Samad Gholamzadeh on 9/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import ModelAssistant

protocol EntityWithImage {
	
	var image: UIImage? { get set}
	var imageURL: URL { get }

}

protocol CustomMAEntity: MAEntity, EntityWithImage {
	
	init?(data: [String : Any])
}
