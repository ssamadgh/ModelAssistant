/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Shows how to lift operation-like objects in to the NSOperation world.
 */

import Foundation


/**
 `URLSessionTaskOperation` is an `AOperation` that lifts an `NSURLSessionTask`
 into an operation.

 Note that this operation does not participate in any of the delegate callbacks \
 of an `NSURLSession`, but instead uses Key-Value-Observing to know when the
 task has been completed. It also does not get notified about any errors that
 occurred during execution of the task.

 An example usage of `URLSessionTaskOperation` can be seen in the `DownloadEarthquakesOperation`.
 */

class URLSessionTaskOperation: AOperation {

	var task: URLSessionTask!


	init(kind: TaskKind = .download, from localURL: URL? = nil, for request: URLRequest, downloadProgress: ((Progress) -> Swift.Void)? = nil, completionHandler: ((URL?, URLResponse?, Error?) -> Swift.Void)? = nil, uploadCompletionHandler: ((Data?, URLResponse?, Error?) -> Swift.Void)? = nil) {
		super.init()

		let task = URLSessionTaskManager.shared.transportTask(kind: kind, from: localURL, for: request, downloadProgress: downloadProgress, completionHandler: { (url, response, error) in

			if let error = error as NSError? {
				self.finishWithError(error as NSError?)
			}
			else {
				completionHandler?(url, response, error)
				self.finishWithError(error as NSError?)
			}

		}, uploadCompletionHandler: { (data, response, error) in

			if let error = error as NSError? {
				self.finishWithError(error as NSError?)
			}
			else {
				uploadCompletionHandler?(data, response, error)
				self.finishWithError(error as NSError?)
			}

		})

		let reachabilityCondition = ReachabilityCondition(host: request.url!)
		self.addCondition(reachabilityCondition)

		let networkObserver = NetworkObserver()
		self.addObserver(networkObserver)


		assert(task.state == .suspended, "Tasks must be suspended.")
		self.task = task
//		super.init()
		name = "URLSessionTaskOperation"

	}


	//    init(task: URLSessionTask) {
	//        assert(task.state == .suspended, "Tasks must be suspended.")
	//        self.task = task
	//        super.init()
	//        name = "URLSessionTaskOperation"
	//    }

	deinit {

	}

	override func execute() {

		assert(task.state == .suspended, "Task was resumed by something other than \(self).")

		task.resume()
	}

	override func cancel() {
		task.cancel()
		super.cancel()
	}
}

