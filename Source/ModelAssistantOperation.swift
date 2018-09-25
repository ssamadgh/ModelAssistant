//
//  ModelOperations.swift
//  Model
//
//  Created by Seyed Samad Gholamzadeh on 9/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

class ModelAssistantOperation: GroupOperation {
	
	init(delegate: ModelAssistantDelegate?, callDelegate: Bool, blockOperation: BlockOperation, completion: @escaping () -> Void) {
		
		let modelAssistantWillChangeOperation = BlockOperation {
			delegate?.modelAssistantWillChangeContent()
		}
		modelAssistantWillChangeOperation.name = "modelAssistantWillChangeOperation"
		
		let modelAssistantDidChangeOperation = BlockOperation {
			delegate?.modelAssistantDidChangeContent()
		}
		modelAssistantDidChangeOperation.name = "modelAssistantDidChangeOperation"

		blockOperation.name = "ModelAssistantOperation blockOperation"
		
		let finishOperation = Foundation.BlockOperation(block: completion)
		finishOperation.name = "ModelAssistantOperation finish Operation"
		
		let operations: [Operation]
		
		if callDelegate {
			blockOperation.addDependency(modelAssistantWillChangeOperation)
			modelAssistantDidChangeOperation.addDependency(blockOperation)
			
			finishOperation.addDependency(modelAssistantDidChangeOperation)
			operations = [modelAssistantWillChangeOperation, blockOperation, modelAssistantDidChangeOperation, finishOperation]
		}
		else {
			finishOperation.addDependency(blockOperation)
			operations = [blockOperation, finishOperation]
		}

		super.init(operations: operations)
		
		name = "ModelAssistant Operation"
	}
	
}
