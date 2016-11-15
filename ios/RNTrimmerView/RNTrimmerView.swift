//
//  RNTrimmerView.swift
//  RNVideoProcessing
//

import UIKit
import AVKit

@objc(RNTrimmerView)
class RNTrimmerView: RCTView, ICGVideoTrimmerDelegate {
  
  var trimmerView: ICGVideoTrimmerView?
  var asset: AVAsset!
  var rect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
  var mThemeColor = UIColor.clear
  
  var source: NSString? {
    set {
      setSource(source: newValue)
    }
    get {
      return nil
    }
  }

  var height: NSNumber? {
    set {
      self.rect.size.height = RCTConvert.cgFloat(newValue)
      self.updateView()
    }
    get {
      return nil
    }
  }
  var width: NSNumber? {
    set {
      self.rect.size.width = RCTConvert.cgFloat(newValue)
      self.updateView()
    }
    get {
      return nil
    }
  }
  var themeColor: NSString? {
    set {
      if newValue != nil {
        let color = NumberFormatter().number(from: newValue! as String)
        self.mThemeColor = RCTConvert.uiColor(color)
        self.updateView()
      }
    }
    get {
      return nil
    }
  }
  func updateView() {
    self.frame = rect
    if trimmerView != nil {
      self.trimmerView!.frame = rect
      self.trimmerView!.themeColor = self.mThemeColor
      self.layoutIfNeeded()
      trimmerView!.resetSubviews()
    }
  }
  
  func setSource(source: NSString?) {
    if source != nil {
//      let pathToSource = Bundle.main.path(forResource: source! as String, ofType: "mp4")
      let pathToSource = Bundle.main.path(forResource: "Simons_Cat", ofType: "mp4")
      let videoPath = NSURL.init(fileURLWithPath: pathToSource!) as URL
      self.asset = AVAsset(url: videoPath)
      
      trimmerView = ICGVideoTrimmerView(frame: rect, asset: self.asset)
      trimmerView!.maxLength = CGFloat(self.asset.duration.seconds)
      trimmerView!.showsRulerView = false
      trimmerView!.hideTracker(true)
      trimmerView!.delegate = self
      self.addSubview(trimmerView!)
    }
  }
  
  func trimmerView(_ trimmerView: ICGVideoTrimmerView, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
    print("Trimmer, \(startTime) : \(endTime)")
  }

}
