/**
ModelOperations.swift
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
