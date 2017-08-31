//
//  RNVideoPlayer.swift
//  RNVideoProcessing
//
//  Created by Shahen Hovhannisyan on 11/14/16.

import Foundation
import AVFoundation
import GPUImage

@objc(RNVideoPlayer)
class RNVideoPlayer: RCTView {
    
    let processingFilters: VideoProcessingGPUFilters = VideoProcessingGPUFilters()
    
    var playerVolume: NSNumber = 0
    var player: AVPlayer! = nil
    var playerLayer: AVPlayerLayer?
    
    var playerCurrentTimeObserver: Any! = nil
    var playerItem: AVPlayerItem! = nil
    var gpuMovie: GPUImageMovie! = nil
    
    var phantomGpuMovie: GPUImageMovie! = nil
    var phantomFilterView: GPUImageView = GPUImageView()
    
    let filterView: GPUImageView = GPUImageView()
    
    var _playerHeight: CGFloat = UIScreen.main.bounds.width * 4 / 3
    var _playerWidth: CGFloat = UIScreen.main.bounds.width
    var _moviePathSource: NSString = ""
    var _playerStartTime: CGFloat = 0
    var _playerEndTime: CGFloat = 0
    var _replay: Bool = false
    var _rotate: Bool = false
    var isInitialized = false
    var _resizeMode = AVLayerVideoGravityResizeAspect
    var onChange: RCTBubblingEventBlock?
    
    let LOG_KEY: String = "VIDEO_PROCESSING"
    
    // props
    var playerHeight: NSNumber? {
        set(val) {
            if val != nil {
                self._playerHeight = val as! CGFloat
                self.frame.size.height = self._playerHeight
                self.rotate = self._rotate ? 1 : 0
                print("CHANGED HEIGHT \(val)")
            }
        }
        get {
            return nil
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer = AVPlayerLayer.init(player: player)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var resizeMode: NSString? {
        set {
            if newValue == nil {
                return
            }
            self._resizeMode = newValue as! String
            self.playerLayer?.videoGravity = self._resizeMode
            self.setNeedsLayout()
            print("CHANGED: resizeMode \(newValue)")
        }
        get {
            return nil
        }
    }
    
    var playerWidth: NSNumber? {
        set(val) {
            if val != nil {
                self._playerWidth = val as! CGFloat
                self.frame.size.width = self._playerWidth
                self.rotate = self._rotate ? 1 : 0
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
                print("CHANGED source \(val)")
                if self.gpuMovie != nil {
                    self.gpuMovie.endProcessing()
                }
                self.startPlayer()
            }
        }
        get {
            return nil
        }
    }
    
    // props
    var currentTime: NSNumber? {
        set(val) {
            if val != nil && player != nil {
                let convertedValue = val as! CGFloat
                let floatVal = convertedValue >= 0 ? convertedValue : self._playerStartTime
                print("CHANGED: currentTime \(floatVal)")
                if floatVal <= self._playerEndTime && floatVal >= self._playerStartTime {
                    self.player.seek(to: convertToCMTime(val: floatVal), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
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
            let convertedValue = val as! CGFloat
            
            self._playerStartTime = convertedValue
            
            if convertedValue < 0 {
                print("WARNING: startTime is a negative number: \(val)")
                self._playerStartTime = 0.0
            }
            
            let currentTime = CGFloat(CMTimeGetSeconds(player.currentTime()))
            var shouldBeCurrentTime: CGFloat = currentTime;
            
            if self._playerStartTime > currentTime {
                shouldBeCurrentTime = self._playerStartTime
            }
            
            if player != nil {
                player.seek(
                    to: convertToCMTime(val: shouldBeCurrentTime),
                    toleranceBefore: convertToCMTime(val: self._playerStartTime),
                    toleranceAfter: convertToCMTime(val: self._playerEndTime)
                )
            }
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
            let convertedValue = val as! CGFloat
            
            self._playerEndTime = convertedValue
            
            if convertedValue < 0.0 {
                print("WARNING: endTime is a negative number: \(val)")
                self._playerEndTime = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
            }
            
            let currentTime = CGFloat(CMTimeGetSeconds(player.currentTime()))
            var shouldBeCurrentTime: CGFloat = currentTime;
            
            if self._playerEndTime < currentTime {
                shouldBeCurrentTime = self._playerStartTime
            }
            
            if player != nil {
                player.seek(
                    to: convertToCMTime(val: shouldBeCurrentTime),
                    toleranceBefore: convertToCMTime(val: self._playerStartTime),
                    toleranceAfter: convertToCMTime(val: self._playerEndTime)
                )
            }
            print("CHANGED endTime \(val)")
        }
        get {
            return nil
        }
    }
    
    var play: NSNumber? {
        set(val) {
            if val == nil || player == nil {
                return
            }
            print("CHANGED play \(val)")
            if val == 1 && player.rate == 0.0 {
                player.play()
            } else if val == 0 && player.rate != 0.0 {
                player.pause()
            }
        }
        get {
            return nil
        }
    }
    
    var replay: NSNumber? {
        set(val) {
            if val != nil  {
                self._replay = RCTConvert.bool(val!)
            }
        }
        get {
            return nil
        }
    }
    
    var rotate: NSNumber? {
        set(val) {
            if val != nil {
                self._rotate = RCTConvert.bool(val!)
                var rotationAngle: CGFloat = 0
                if self._rotate {
                    filterView.frame.size.width = self._playerHeight
                    filterView.frame.size.height = self._playerWidth
                    filterView.bounds.size.width = self._playerHeight
                    filterView.bounds.size.height = self._playerWidth
                    rotationAngle = CGFloat(M_PI_2)
                } else {
                    filterView.frame.size.width = self._playerWidth
                    filterView.frame.size.height = self._playerHeight
                    filterView.bounds.size.width = self._playerWidth
                    filterView.bounds.size.height = self._playerHeight
                }
                filterView.frame.origin = CGPoint.zero
                self.filterView.transform = CGAffineTransform(rotationAngle: rotationAngle)
                playerLayer?.frame = filterView.bounds
                self.setNeedsLayout()
                self.layoutIfNeeded()
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
                self.onVideoCurrentTimeChange(currentTime: currentTime)
                if currentTime >= self._playerEndTime {
                    if self._replay {
                        return self.replayMovie()
                    }
                    self.play = 0
                }
        }
        )
    }
    
    func replayMovie() {
        if player != nil {
            self.player.seek(to: convertToCMTime(val: self._playerStartTime))
            self.player.play()
        }
    }
    
    func onVideoCurrentTimeChange(currentTime: CGFloat) {
        if self.onChange != nil {
            let event = ["currentTime": currentTime]
            self.onChange!(event)
        }
    }
    
    // start player
    func startPlayer() {
        self.backgroundColor = UIColor.darkGray
        
        let movieURL = NSURL(string: _moviePathSource as String)
        
        if self.player == nil {
            player = AVPlayer()
            player.volume = Float(self.playerVolume)
        }
        playerItem = AVPlayerItem(url: movieURL as! URL)
        player.replaceCurrentItem(with: playerItem)
        
        // MARK - Temporary removing playeLayer, it dublicates video if it's in landscape mode
        //        playerLayer = AVPlayerLayer(player: player)
        //        playerLayer!.frame = filterView.bounds
        //        playerLayer!.videoGravity = self._resizeMode
        //        playerLayer!.masksToBounds = true
        //        playerLayer!.removeFromSuperlayer()
        //        filterView.layer.addSublayer(playerLayer!)
        
        print("CHANGED playerframe \(playerLayer), frameAAA \(playerLayer?.frame)")
        self.setNeedsLayout()
        
        self._playerEndTime = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
        print("CHANGED playerEndTime \(self._playerEndTime)")
        
        if self.gpuMovie != nil {
            gpuMovie.endProcessing()
        }
        gpuMovie = GPUImageMovie(playerItem: playerItem)
        // gpuMovie.runBenchmark = true
        gpuMovie.playAtActualSpeed = true
        gpuMovie.startProcessing()
        
        gpuMovie.addTarget(self.filterView)
        if !self.isInitialized {
            self.addSubview(filterView)
            self.createPlayerObservers()
        }
        gpuMovie.playAtActualSpeed = true
        
        self.isInitialized = true
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            
            if self.playerCurrentTimeObserver != nil {
                self.player.removeTimeObserver(self.playerCurrentTimeObserver)
            }
            if player != nil {
                self.player.pause()
                self.gpuMovie.cancelProcessing()
                self.player = nil
                self.gpuMovie = nil
                print("CHANGED: Removing Observer, that can be a cause of memory leak")
            }
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
