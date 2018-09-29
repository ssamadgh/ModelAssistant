//
//  URLSessionTaskManager.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 11/28/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

struct Progress {

	var completedUnitCount: Double
	var totalUnitCount: Double
	var fractionCompleted: Double

	init(total: Double, completed: Double) {
		self.totalUnitCount = total
		self.completedUnitCount = completed
		self.fractionCompleted = completed/total
	}
}

enum TaskKind {
	case download, upload
}


struct HTTPMethod {

	static var get = "GET"
	static var post = "POST"
	static var put = "PUT"
	static var delete = "DELETE"
}

class URLSessionTaskManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

	public static var shared: URLSessionTaskManager = {
		return URLSessionTaskManager()
	}()

	var downloadTaskFinisedDic: [Int : (URL?, URLResponse?, Error?) -> Swift.Void] = [:]
	var uploadTaskFinisedDic: [Int : (Data?, URLResponse?, Error?) -> Swift.Void] = [:]
	var taskProgressDic: [Int : (Progress) -> Swift.Void] = [:]

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		print("Hello, totalBytesWritten, totalBytesExpectedToWrite ")
		let progress = Progress(total: Double(totalBytesExpectedToWrite), completed: Double(totalBytesWritten))
//		self.taskProgress?(progress)
		let taskProgress = self.taskProgressDic[downloadTask.taskIdentifier]
		taskProgress?(progress)
	}

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

		let url = location
		let response = downloadTask.response
		let error = downloadTask.error
//		self.downloadTaskFinised?(url, response, error)
		let downloadTaskFinised = self.downloadTaskFinisedDic[downloadTask.taskIdentifier]
		downloadTaskFinised?(url, response, error)
		self.taskProgressDic.removeValue(forKey: downloadTask.taskIdentifier)
		self.downloadTaskFinisedDic.removeValue(forKey: downloadTask.taskIdentifier)
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {

		print("uploading data didSendBodyData")
		let progress = Progress(total: Double(totalBytesExpectedToSend), completed: Double(totalBytesSent))
//		self.taskProgress?(progress)
		let taskProgress = self.taskProgressDic[task.taskIdentifier]
		taskProgress?(progress)
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		print("task Finished didCompleteWithError")
//		let url: URL? = nil
//		let response = task.response
//		let error = error
//		self.downloadTaskFinised?(url, response, error)
	}

	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		print("task Finished didReceive data")
		let response = dataTask.response
		let error = dataTask.error
//		self.uploadTaskFinised?(data, response, error)

		let uploadTaskFinised = self.uploadTaskFinisedDic[dataTask.taskIdentifier]
		uploadTaskFinised?(data, response, error)
		self.uploadTaskFinisedDic.removeValue(forKey: dataTask.taskIdentifier)
		self.taskProgressDic.removeValue(forKey: dataTask.taskIdentifier)
	}

	private lazy var session: URLSession = {
		let configuration = URLSessionConfiguration.default
		let session = URLSession(configuration: configuration, delegate:self , delegateQueue: nil)

		return session
	}()

//	func getData(kind: TaskKind = .download, from localURL: URL? = nil, for request: URLRequest, downloadProgress: ((Progress) -> Swift.Void)? = nil, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Swift.Void, uploadCompletionHandler: ((Data?, URLResponse?, Error?) -> Swift.Void)? = nil) -> URLSessionTaskOperation {
//
//		let task = transportTask(kind: kind, from: localURL, for: request, downloadProgress: downloadProgress, completionHandler: completionHandler, uploadCompletionHandler: uploadCompletionHandler)
//
//		return operation(for: task, with: request.url!)
//	}


	func transportTask(kind: TaskKind, from localURL: URL?, for request: URLRequest, downloadProgress: ((Progress) -> Swift.Void)? = nil, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Swift.Void, uploadCompletionHandler: ((Data?, URLResponse?, Error?) -> Swift.Void)?) -> URLSessionTask {

		if kind == .download {

			if downloadProgress != nil {
				let delegateTask = session.downloadTask(with: request)
				self.downloadTaskFinisedDic[delegateTask.taskIdentifier] = completionHandler
				self.taskProgressDic[delegateTask.taskIdentifier] = downloadProgress

				return delegateTask
			}
			else {

				let task = session.downloadTask(with: request, completionHandler: completionHandler)
				return task
			}
		}
		else {
			let upload = session.uploadTask(withStreamedRequest: request)
			self.uploadTaskFinisedDic[upload.taskIdentifier] = uploadCompletionHandler
			self.taskProgressDic[upload.taskIdentifier] = downloadProgress

			return upload
		}

	}


//	private func operation(for task: URLSessionTask, with url: URL) -> URLSessionTaskOperation {
//		let taskOperation = URLSessionTaskOperation(task: task)
//
//		let reachabilityCondition = ReachabilityCondition(host: url)
//		taskOperation.addCondition(reachabilityCondition)
//
//		return taskOperation
//	}

	static var headers: [String : String]? {
		let headers = [
			"Content-Type" : "application/json",
			]
		return headers
	}


}

