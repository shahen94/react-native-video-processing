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
  var onChange: RCTBubblingEventBlock?
  var _minLength: CGFloat? = nil
  var _maxLength: CGFloat? = nil

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

  var maxLength: NSNumber? {
    set {
      if newValue != nil {
        self._maxLength = RCTConvert.cgFloat(newValue!)
        self.updateView()
      }
    }
    get {
      return nil
    }
  }

  var minLength: NSNumber? {
    set {
      if newValue != nil {
        self._minLength = RCTConvert.cgFloat(newValue!)
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
      trimmerView!.frame = rect
      trimmerView!.themeColor = self.mThemeColor
      trimmerView!.maxLength = _maxLength == nil ? CGFloat(self.asset.duration.seconds) : _maxLength!
      if _minLength != nil {
        trimmerView!.minLength = _minLength!
      }
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
    if self.onChange != nil {
      let event = ["startTime": startTime, "endTime": endTime]
      self.onChange!(event)
    }
  }

  func trimmerView(_ trimmerView: ICGVideoTrimmerView, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
    onTrimmerPositionChange(startTime: startTime, endTime: endTime)
  }
}
