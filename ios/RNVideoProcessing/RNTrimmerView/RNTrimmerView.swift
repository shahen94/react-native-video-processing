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
  var rect: CGRect = CGRect.zero
  var mThemeColor = UIColor.clear
  var bridge: RCTBridge!

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
      self.trimmerView!.resetSubviews()
      Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTrimmer), userInfo: nil, repeats: false)
    }
  }

  func updateTrimmer() {
    self.trimmerView!.resetSubviews()
  }

  func setSource(source: NSString?) {
    if source != nil {
      let pathToSource = NSURL(string: source! as String)
      self.asset = AVURLAsset(url: pathToSource as! URL, options: nil)

      trimmerView = ICGVideoTrimmerView(frame: rect, asset: self.asset)
      trimmerView!.maxLength = CGFloat(self.asset.duration.seconds)
      trimmerView!.showsRulerView = false
      trimmerView!.hideTracker(true)
      trimmerView!.delegate = self
      trimmerView!.trackerColor = UIColor.clear
      self.addSubview(trimmerView!)
      self.updateView()
    }
  }

  init(frame: CGRect, bridge: RCTBridge) {
    super.init(frame: frame)
    self.bridge = bridge
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func onTrimmerPositionChange(startTime: CGFloat, endTime: CGFloat) {
    if (self.bridge != nil && self.bridge.eventDispatcher() != nil) {
      let event = ["startTime": startTime, "endTime": endTime]
      self.bridge.eventDispatcher().sendAppEvent(withName: "VIDEO_PROCESSING_EVENT_TRIMMER", body: event)
    }
  }

  func trimmerView(_ trimmerView: ICGVideoTrimmerView, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
    onTrimmerPositionChange(startTime: startTime, endTime: endTime)
  }
}
