//
//  ModelOperations.swift
//  Model
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

class ModelOperation: GroupOperation {
	
	init(delegate: ModelDelegate?, callDelegate: Bool, blockOperation: BlockOperation, completion: @escaping () -> Void) {
		
		let modelWillChangeOperation = BlockOperation {
			delegate?.modelWillChangeContent()
		}
		modelWillChangeOperation.name = "modelWillChangeOperation"
		
		let modelDidChangeOperation = BlockOperation {
			delegate?.modelDidChangeContent()
		}
		modelDidChangeOperation.name = "modelDidChangeOperation"

		blockOperation.name = "ModelOperation blockOperation"
		
		let finishOperation = Foundation.BlockOperation(block: completion)
		finishOperation.name = "ModelOperation finish Operation"
		
		let operations: [Operation]
		
		if callDelegate {
			blockOperation.addDependency(modelWillChangeOperation)
			modelDidChangeOperation.addDependency(blockOperation)
			
			finishOperation.addDependency(modelDidChangeOperation)
			operations = [modelWillChangeOperation, blockOperation, modelDidChangeOperation, finishOperation]
		}
		else {
			finishOperation.addDependency(blockOperation)
			operations = [blockOperation, finishOperation]
		}

		super.init(operations: operations)
		
		name = "Model Operation"
	}
	
}
