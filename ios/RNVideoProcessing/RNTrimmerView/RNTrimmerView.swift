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
    var onTrackerMove: RCTBubblingEventBlock?
    var _minLength: CGFloat? = nil
    var _maxLength: CGFloat? = nil
    var _thumbWidth: CGFloat? = nil
    var _trackerColor: UIColor = UIColor.clear
    var _trackerHandleColor: UIColor = UIColor.clear
    var _showTrackerHandle = false
    
    var source: NSString? {
        set {
            setSource(source: newValue)
        }
        get {
            
            return nil
        }
    }
    
    var showTrackerHandle: NSNumber? {
        set {
            if newValue == nil {
                return
            }
            let _nVal = newValue! == 1 ? true : false
            if _showTrackerHandle != _nVal {
                print("CHANGED: showTrackerHandle \(newValue!)");
                _showTrackerHandle = _nVal
                self.updateView()
            }
        }
        get {
            return nil
        }
    }
    
    var trackerHandleColor: NSString? {
        set {
            if newValue != nil {
                let color = NumberFormatter().number(from: newValue! as String)
                let formattedColor = RCTConvert.uiColor(color)
                if formattedColor != nil {
                    print("CHANGED: trackerHandleColor: \(newValue!)")
                    self._trackerHandleColor = formattedColor!
                    self.updateView();
                }
            }
        }
        get {
            return nil
        }
    }
    
    var height: NSNumber? {
        set {
            self.rect.size.height = RCTConvert.cgFloat(newValue) + 40
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
    
    var thumbWidth: NSNumber? {
        set {
            if newValue != nil {
                self._thumbWidth = RCTConvert.cgFloat(newValue!)
                self.updateView()
            }
        }
        get {
            return nil
        }
    }
    
    var currentTime: NSNumber? {
        set {
            print("CHANGED: [TrimmerView]: currentTime: \(newValue)")
            if newValue != nil && self.trimmerView != nil {
                let convertedValue = newValue as! CGFloat
                self.trimmerView?.seek(toTime: convertedValue)
                //        self.trimmerView
            }
        }
        get {
            return nil
        }
    }
    
    var trackerColor: NSString? {
        set {
            if newValue == nil {
                return
            }
            print("CHANGED: trackerColor \(newValue!)")
            let color = NumberFormatter().number(from: newValue! as String)
            let formattedColor = RCTConvert.uiColor(color)
            if formattedColor != nil {
                self._trackerColor = formattedColor!
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
            trimmerView!.trackerColor = self._trackerColor
            trimmerView!.trackerHandleColor = self._trackerHandleColor
            trimmerView!.showTrackerHandle = self._showTrackerHandle
            trimmerView!.maxLength = _maxLength == nil ? CGFloat(self.asset.duration.seconds) : _maxLength!
            self.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height + 20)
            if _minLength != nil {
                trimmerView!.minLength = _minLength!
            }
            if _thumbWidth != nil {
                trimmerView!.thumbWidth = _thumbWidth!
            }
            self.trimmerView!.resetSubviews()
            //      Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTrimmer), userInfo: nil, repeats: false)
        }
    }
    
    func updateTrimmer() {
        self.trimmerView!.resetSubviews()
    }
    
    func setSource(source: NSString?) {
        if source != nil {
            let pathToSource = NSURL(string: source! as String)
            self.asset = AVURLAsset(url: pathToSource! as URL, options: nil)
            
            trimmerView = ICGVideoTrimmerView(frame: rect, asset: self.asset)
            trimmerView!.showsRulerView = false
            trimmerView!.hideTracker(false)
            trimmerView!.delegate = self
            trimmerView!.trackerColor = self._trackerColor
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
    
    public func trimmerView(_ trimmerView: ICGVideoTrimmerView, currentPosition currentTime: CGFloat) {
        print("current", currentTime)
        if onTrackerMove == nil {
            return
        }
        let event = ["currentTime": currentTime]
        self.onTrackerMove!(event)
    }
}
