//
//  RNVideoPlayer.swift
//  RNVideoProcessing
//
//  Created by Shahen Hovhannisyan on 11/14/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Foundation
import GPUImage
import AVFoundation
//import AVKit

@objc(RNVideoPlayer)
class RNVideoPlayer: RCTView {

  let processingFilters: VideoProcessingGPUFilters = VideoProcessingGPUFilters()
  let EVENTS = (
    SEND_PREVIEWS: "VIDEO_PROCESSING:PREVIEWS"
  )

  var playerVolume: NSNumber = 0
  var player: AVPlayer! = nil
  var playerCurrentTimeObserver: Any! = nil
  var playerItem: AVPlayerItem! = nil
  var playerLayer: AVPlayerLayer! = nil
  var gpuMovie: GPUImageMovie! = nil

  var phantomGpuMovie: GPUImageMovie! = nil
  var phantomFilterView: GPUImageView = GPUImageView()

  let filterView: GPUImageView = GPUImageView()
  var bridge: RCTBridge! = nil

  var _playerHeight: CGFloat = UIScreen.main.bounds.height / 3
  var _playerWidth: CGFloat = UIScreen.main.bounds.width
  var _moviePathSource: NSString = ""
  var _playerStartTime: CGFloat = 0
  var _playerEndTime: CGFloat = 0

  let LOG_KEY: String = "VIDEO_PROCESSING"

  init(frame: CGRect, bridge: RCTBridge) {
    super.init(frame: frame)
    self.bridge = bridge

    self.startPlayer()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // props
  var playerHeight: NSNumber? {
    set(val) {
      if val != nil {
        self._playerHeight = val as! CGFloat
        filterView.frame.size.height = self._playerHeight
        print("CHANGED HEIGHT \(val)")
      }
    }
    get {
      return nil
    }
  }

  var playerWidth: NSNumber? {
    set(val) {
      if val != nil {
        self._playerWidth = val as! CGFloat
        filterView.frame.size.width = self._playerWidth
        print("CHANGED WIDTH \(val)")
      }
    }
    get {
      return nil
    }
  }


  // props
    var source: NSString? {
        set(val) {
          if val != nil {
            self._moviePathSource = val!
          }
        }
        get {
            return nil
        }
    }

  // props
    var currentTime: NSNumber? {
        set(val) {
          if val != nil {
            let floatVal = val as! CGFloat
            if floatVal <= self._playerEndTime && floatVal >= self._playerStartTime {
              player.seek(to: CMTimeMakeWithSeconds(Float64(val!), Int32(NSEC_PER_SEC)))
            }
          }
        }
        get {
            return nil
        }
    }

  // props
    var startTime: NSNumber? {
        set(val) {
          if val == nil {
            return
          }
          self._playerStartTime = val as! CGFloat
          let currentTime = CGFloat(CMTimeGetSeconds(player.currentTime()))
          var shouldBeCurrentTime: CGFloat = currentTime;

          if self._playerStartTime > currentTime {
            shouldBeCurrentTime = self._playerStartTime
          }
          player.seek(
            to: convertToCMTime(val: shouldBeCurrentTime),
            toleranceBefore: convertToCMTime(val: self._playerStartTime),
            toleranceAfter: convertToCMTime(val: self._playerEndTime)
          )
          print("CHANGED startTime \(val)")
        }
        get {
            return nil
        }
    }

  // props
    var endTime: NSNumber? {
        set(val) {
          if val == nil {
            return
          }
          self._playerEndTime = val as! CGFloat
          let currentTime = CGFloat(CMTimeGetSeconds(player.currentTime()))
          var shouldBeCurrentTime: CGFloat = currentTime;

          if self._playerEndTime < currentTime {
            shouldBeCurrentTime = self._playerStartTime
          }

          player.seek(
            to: convertToCMTime(val: shouldBeCurrentTime),
            toleranceBefore: convertToCMTime(val: self._playerStartTime),
            toleranceAfter: convertToCMTime(val: self._playerEndTime)
          )
          print("CHANGED endTime \(val)")
        }
        get {
            return nil
        }
    }

  var play: NSNumber? {
    set(val) {
      if val == nil {
        return
      }
      print("CHANGED play \(val)")
      if val == 1 && player.rate == 0.0 {
        gpuMovie.startProcessing()
        player.play()
      } else if val == 0 && player.rate != 0.0 {
        gpuMovie.cancelProcessing()
        player.pause()
      }
    }
    get {
      return nil
    }
  }

  var volume: NSNumber? {
    set(val) {
      let minValue: NSNumber = 0

      if val == nil {
        return
      }
      if (val?.floatValue)! < minValue.floatValue {
        return
      }
      self.playerVolume = val!
      if player != nil {
        player.volume = self.playerVolume.floatValue
      }
    }
    get {
      return nil
    }
  }

  func generatePreviewImages() -> Void {
    let hueFilter = self.processingFilters.getFilterByName(name: "hue")
    gpuMovie.removeAllTargets()
    gpuMovie.addTarget(hueFilter)
    hueFilter?.addTarget(self.filterView)
    gpuMovie.startProcessing()
    player.play()
    hueFilter?.useNextFrameForImageCapture()

    let huePreview = hueFilter?.imageFromCurrentFramebuffer()
    if huePreview != nil {
      print("CREATED: Preview: Hue: \(toBase64(image: huePreview!))")
    }
  }

  func toBase64(image: UIImage) -> String {
    let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
    return imageData.base64EncodedString(options: .lineLength64Characters)
  }

  func convertToCMTime(val: CGFloat) -> CMTime {
    return CMTimeMakeWithSeconds(Float64(val), Int32(NSEC_PER_SEC))
  }

  func createPlayerObservers() -> Void {
    // TODO: clean obersable when View going to diesappear
    let interval = CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC))
    self.playerCurrentTimeObserver = self.player.addPeriodicTimeObserver(
      forInterval: interval,
      queue: nil,
      using: {(_ time: CMTime) -> Void in
        let currentTime = CGFloat(CMTimeGetSeconds(time))
        if currentTime >= self._playerEndTime {
          self.play = 0
        }
      }
    )
  }


  // start player
  func startPlayer() {
    self.backgroundColor = UIColor.darkGray

    let bundleURL = Bundle.main.resourceURL!
    let movieURL = URL(string: "2.mp4", relativeTo: bundleURL)!

    player = AVPlayer()
    player.volume = Float(self.playerVolume)
    playerItem = AVPlayerItem(url: movieURL)
    player.replaceCurrentItem(with: playerItem)

    if _playerEndTime == 0 {
      self._playerEndTime = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
      print("CHANGED playerEndTime \(self._playerEndTime)")
    }


    gpuMovie = GPUImageMovie(playerItem: playerItem)
    // gpuMovie.runBenchmark = true
    gpuMovie.playAtActualSpeed = true

    filterView.frame = self.frame

    filterView.frame.size.width = self._playerWidth
    filterView.frame.size.height = self._playerHeight

    gpuMovie.addTarget(self.filterView)
    self.addSubview(filterView)
    print("SUBS: \(self.subviews)")
    gpuMovie.playAtActualSpeed = true

    self.createPlayerObservers()
  }

  override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    if newSuperview == nil {

      if self.playerCurrentTimeObserver != nil {
        self.player.removeTimeObserver(self.playerCurrentTimeObserver)
      }
      self.player.pause()
      self.gpuMovie.cancelProcessing()
      self.player = nil
      self.gpuMovie = nil
      print("CHANGED: Removing Oberver, that can be a cause of memory leak")
    }
  }
  /* @TODO: create Preview images before the next Release
  func createPhantomGPUView() {
    phantomGpuMovie = GPUImageMovie(playerItem: self.playerItem)
    phantomGpuMovie.playAtActualSpeed = true

    let hueFilter = self.processingFilters.getFilterByName(name: "saturation")
    phantomGpuMovie.addTarget(hueFilter)
    phantomGpuMovie.startProcessing()
    hueFilter?.addTarget(phantomFilterView)
    hueFilter?.useNextFrameForImageCapture()
    let CGImage = hueFilter?.newCGImageFromCurrentlyProcessedOutput()
    print("CREATED: CGImage \(CGImage)")
    if CGImage != nil {
      print("CREATED: \(UIImage(cgImage: (CGImage?.takeUnretainedValue() )!))")
    }
    // let image = UIImage(cgImage: (hueFilter?.newCGImageFromCurrentlyProcessedOutput().takeRetainedValue())!)

  }
 */
}
