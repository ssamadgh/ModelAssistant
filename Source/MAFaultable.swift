/**
MAFaultable.swift
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
import UIKit

/**
An abstract protocol used by objects inserted to model assistant, and gives it
the ability to being fault.

Fault means some of the entity properties might be nil and needs to be retrieve.

This feature gives the entity object the ability to release memory and make it free
at the low memory state or other situations which needs to The amount of memory usage
be controlled.

Note that adopting to this protocol for your object is optional.
*/
public protocol MAFaultable {

	/**
	A Boolean value indicating whether the entity is fault.

	When you need to check whether your entity is fault, use the isFoult property.
	Fault means some of the entity properties might be nil and needs to be retrieve.
	*/
	var isFault: Bool { get set }

	/**
	Use this method to set value of some of entiy properties to nil.

	This method is used by model assistant, when its fault method being called.
	Be careful, the properties you set nil in this method can be retrieved by fire() method
	or in another way.

	By default this method does nothing
	*/
	mutating func fault()


	/**
	Use this method to retrieve value of some of entiy properties
	which being nil by fault() method.

	This method is used by model assistant, when its fire method being called.

	By default this method does nothing
	*/
	mutating func fire()
}
