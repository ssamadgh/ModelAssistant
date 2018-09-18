//
//  IconDownloader.swift
//  LazyTable
//
//  Created by Seyed Samad Gholamzadeh on 6/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract: Helper object for managing the downloading of a particular object's icon.
*/

import UIKit

protocol ImageDownloaderDelegate {
	
	func downloaded<T>(_ image: UIImage?, forEntity entity: T)
	
}

let kAppIconSize: CGFloat = 48

class ImageDownloader<T>: NSObject {

	
	var delegate: ImageDownloaderDelegate!
	var imageTask: URLSessionTask!
	
	let imageURL: URL
	let entity: T
	
	init(from imageURL: URL, forEntity entity: T) {
		self.imageURL = imageURL
		self.entity = entity
	}

	func startDownload() {

		let task = URLSession.shared.dataTask(with: URLRequest(url: imageURL)) { (data, responce, error) in
			
			var resultImage: UIImage?
			
			if error == nil {

				guard data != nil,
					let image = UIImage(data: data!)
					else { return }
				
				if image.size.width != kAppIconSize || image.size.height != kAppIconSize {
					
					let itemSize = CGSize(width: kAppIconSize, height: kAppIconSize)
					
					UIGraphicsBeginImageContext(itemSize)
					let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height)
					image.draw(in: imageRect)
					resultImage = UIGraphicsGetImageFromCurrentImageContext()
					UIGraphicsEndImageContext()

				}
				else {
					resultImage = image
				}
			}
			
			// call our delegate and tell it that our icon is ready for display
			DispatchQueue.main.async {
				self.delegate.downloaded(resultImage, forEntity: self.entity)
			}
		}
		
		self.imageTask = task
		task.resume()
	}
	
	func cancelDownload() {
		self.imageTask.cancel()
		self.imageTask = nil
	}
}
