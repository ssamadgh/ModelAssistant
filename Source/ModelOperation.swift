//
//  ModelOperations.swift
//  Model
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

class ModelOperation: GroupOperation {
	
	init(delegate: ModelDelegate?, blockOperation: BlockOperation, completion: @escaping () -> Void) {
		
		let modelWillChangeOperation = BlockOperation {
			delegate?.modelWillChangeContent()
		}
		
		let modelDidChangeOperation = BlockOperation {
			delegate?.modelDidChangeContent()
		}

		let finishOperation = Foundation.BlockOperation(block: completion)

		blockOperation.addDependency(modelWillChangeOperation)
		modelDidChangeOperation.addDependency(blockOperation)
		finishOperation.addDependency(modelDidChangeOperation)
		
		super.init(operations: [modelWillChangeOperation, blockOperation, modelDidChangeOperation, finishOperation])
		
		name = "Model Operation"
	}
	
}
