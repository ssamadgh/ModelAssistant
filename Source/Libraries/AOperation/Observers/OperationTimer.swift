/*
  OperationTimer.swift
  MyOperationPractice

  Created by Seyed Samad Gholamzadeh on 7/14/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.

 Abstract:
     Contains the code to manage the visibility of the network activity indicator
*/




/// Essentially a cancelable `dispatch_after`.
class OperationTimer {
    //MARK: Properties

    fileprivate var isCancelled = false

    //MARK: Initialiazation

    init(interval: TimeInterval, handler: @escaping () -> Void) {
        let when = DispatchTime.now() + Double(Int64(interval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

        DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
            if self?.isCancelled == false {
                handler()
            }
        }
    }

    func cancel() {
        isCancelled = true
    }
}
