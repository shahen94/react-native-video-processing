//
//  RNVideoProcessingManager.swift
//  RNVideoProcessing
//
//  Created by Shahen Hovhannisyan on 11/14/16.
//

import Foundation

@objc(RNVideoProcessingManager)
class RNVideoProcessingManager: RCTViewManager {

   @objc override func view() -> UIView! {
       return RNVideoPlayer()
   }

    @objc override func constantsToExport() -> [AnyHashable: Any] {
        return [
            "ScaleNone": AVLayerVideoGravityResizeAspect,
            "ScaleToFill": AVLayerVideoGravityResize,
            "ScaleAspectFit": AVLayerVideoGravityResizeAspect,
            "ScaleAspectFill": AVLayerVideoGravityResizeAspectFill
        ]
    }

    override class func requiresMainQueueSetup() -> Bool {
        return true
    }
}
