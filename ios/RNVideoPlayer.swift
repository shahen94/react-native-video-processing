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
  var player: AVPlayer! = nil
  var playerCurrentTimeObserver: Any! = nil
  var playerItem: AVPlayerItem! = nil
  var playerLayer: AVPlayerLayer! = nil
  var gpuMovie: GPUImageMovie! = nil
  let filterView: GPUImageView = GPUImageView()

  var _playerHeight: CGFloat = UIScreen.main.bounds.height / 3
  var _playerWidth: CGFloat = UIScreen.main.bounds.width
  var _moviePathSource: NSString = ""
  var _playerStartTime: CGFloat = 0
  var _playerEndTime: CGFloat = 0

  let LOG_KEY: String = "VIDEO_PROCESSING"

  deinit {
    if self.playerCurrentTimeObserver != nil {
      self.player.removeTimeObserver(self.playerCurrentTimeObserver)
      print("CHANGED: Removing Oberver, that can be a cause of memory leak")
    }
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
            self.startPlayer()
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
            print("CHANGED currentTime \(val)")
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
        print("CHANGED [playing] \(time)")
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


    print(self.frame.size.height)
    self.addSubview(filterView)
    gpuMovie.playAtActualSpeed = true

    let filter = GPUImageSepiaFilter()
    gpuMovie.addTarget(filter)
    filter.addTarget(filterView)

    self.createPlayerObservers()
  }
}
