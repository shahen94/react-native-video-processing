//
//  RNVideoTrimmer.swift
//  RNVideoProcessing
//

import Foundation
import AVFoundation

enum QUALITY_ENUM: String {
  case QUALITY_LOW = "low"
  case QUALITY_MEDIUM = "medium"
  case QUALITY_HIGHEST = "highest"
  case QUALITY_640x480 = "640x480"
  case QUALITY_960x540 = "960x540"
  case QUALITY_1280x720 = "1280x720"
  case QUALITY_1920x1080 = "1920x1080"
  case QUALITY_3840x2160 = "3840x2160"
  case QUALITY_PASS_THROUGH = "passthrough"
}

@objc(RNVideoTrimmer)
class RNVideoTrimmer: NSObject {
  
  @objc func trim(_ source: String, options: NSDictionary, callback: @escaping RCTResponseSenderBlock) {
    
    var sTime = options.object(forKey: "startTime") as? Float
    var eTime = options.object(forKey: "endTime") as? Float
    let quality = ((options.object(forKey: "quality") as? String) != nil) ? options.object(forKey: "quality") as! String : ""
    let saveToCameraRoll = options.object(forKey: "saveToCameraRoll") as? Bool ?? false
    let saveWithCurrentDate = options.object(forKey: "saveWithCurrentDate") as? Bool ?? false
    
    let manager = FileManager.default
    guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    else {
    callback(["Error creating FileManager", NSNull()])
    return
    }
    
    let sourceURL = getSourceURL(source: source)
    let asset = AVAsset(url: sourceURL as URL)
    if eTime == nil {
    eTime = Float(asset.duration.seconds)
    }
    if sTime == nil {
    sTime = 0
    }
    var outputURL = documentDirectory.appendingPathComponent("output")
    do {
    try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
    let name = randomString()
    outputURL = outputURL.appendingPathComponent("\(name).mp4")
    } catch {
    callback([error.localizedDescription, NSNull()])
    print(error)
    }
    
    //Remove existing file
    _ = try? manager.removeItem(at: outputURL)
    
    let useQuality = getQualityForAsset(quality: quality, asset: asset)
    
    print("RNVideoTrimmer passed quality: \(quality). useQuality: \(useQuality)")
    
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: useQuality)
    else {
    callback(["Error creating AVAssetExportSession", NSNull()])
    return
    }
    exportSession.outputURL = NSURL.fileURL(withPath: outputURL.path)
    exportSession.outputFileType = AVFileTypeMPEG4
    exportSession.shouldOptimizeForNetworkUse = true
    
    if saveToCameraRoll && saveWithCurrentDate {
    let metaItem = AVMutableMetadataItem()
    metaItem.key = AVMetadataCommonKeyCreationDate as (NSCopying & NSObjectProtocol)?
    metaItem.keySpace = AVMetadataKeySpaceCommon
    metaItem.value = NSDate() as (NSCopying & NSObjectProtocol)?
    exportSession.metadata = [metaItem]
    }
    
    let startTime = CMTime(seconds: Double(sTime!), preferredTimescale: 1000)
    let endTime = CMTime(seconds: Double(eTime!), preferredTimescale: 1000)
    let timeRange = CMTimeRange(start: startTime, end: endTime)
    
    exportSession.timeRange = timeRange
    exportSession.exportAsynchronously{
    switch exportSession.status {
    case .completed:
    callback( [NSNull(), outputURL.absoluteString] )
    if saveToCameraRoll {
    UISaveVideoAtPathToSavedPhotosAlbum(outputURL.relativePath, self, nil, nil)
    }
    
    case .failed:
    callback( ["Failed: \(exportSession.error)", NSNull()] )
    
    case .cancelled:
    callback( ["Cancelled: \(exportSession.error)", NSNull()] )
    
    default: break
    }
    }
    }
    
    @objc func compress(_ source: String, options: NSDictionary, callback: @escaping RCTResponseSenderBlock) {
    
    var width = options.object(forKey: "width") as? Float
    var height = options.object(forKey: "height") as? Float
    let bitrateMultiplier = options.object(forKey: "bitrateMultiplier") as? Float ?? 1
    let saveToCameraRoll = options.object(forKey: "saveToCameraRoll") as? Bool ?? false
    let minimumBitrate = options.object(forKey: "minimumBitrate") as? Float
    let saveWithCurrentDate = options.object(forKey: "saveWithCurrentDate") as? Bool ?? false
    
    let manager = FileManager.default
    guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    else {
    callback(["Error creating FileManager", NSNull()])
    return
    }
    
    let sourceURL = getSourceURL(source: source)
    let asset = AVAsset(url: sourceURL as URL)
    
    guard let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first else  {
    callback(["Error getting track info", NSNull()])
    return
    }
    
    let naturalSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
    let bps = videoTrack.estimatedDataRate
    width = width ?? Float(abs(naturalSize.width))
    height = height ?? Float(abs(naturalSize.height))
    var averageBitrate = bps / bitrateMultiplier
    if minimumBitrate != nil {
    if averageBitrate < minimumBitrate! {
    averageBitrate = minimumBitrate!
    }
    if bps < minimumBitrate! {
    averageBitrate = bps
    }
    }
    
    var outputURL = documentDirectory.appendingPathComponent("output")
    do {
    try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
    let name = randomString()
    outputURL = outputURL.appendingPathComponent("\(name)-compressed.mp4")
    } catch {
    callback([error.localizedDescription, NSNull()])
    print(error)
    }
    
    //Remove existing file
    _ = try? manager.removeItem(at: outputURL)
    
    let compressionEncoder = SDAVAssetExportSession(asset: asset)
    if compressionEncoder == nil {
    callback(["Error creating AVAssetExportSession", NSNull()])
    return
    }
    compressionEncoder!.outputFileType = AVFileTypeMPEG4
    compressionEncoder!.outputURL = NSURL.fileURL(withPath: outputURL.path)
    compressionEncoder!.shouldOptimizeForNetworkUse = true
    if saveToCameraRoll && saveWithCurrentDate {
    let metaItem = AVMutableMetadataItem()
    metaItem.key = AVMetadataCommonKeyCreationDate as (NSCopying & NSObjectProtocol)?
    metaItem.keySpace = AVMetadataKeySpaceCommon
    metaItem.value = NSDate() as (NSCopying & NSObjectProtocol)?
    compressionEncoder!.metadata = [metaItem]
    }
    compressionEncoder?.videoSettings = [
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: NSNumber.init(value: width!),
    AVVideoHeightKey: NSNumber.init(value: height!),
    AVVideoCompressionPropertiesKey: [
    AVVideoAverageBitRateKey: NSNumber.init(value: averageBitrate),
    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
    ]
    ]
    compressionEncoder?.audioSettings = [
    AVFormatIDKey: kAudioFormatMPEG4AAC,
    AVNumberOfChannelsKey: 1,
    AVSampleRateKey: 44100,
    AVEncoderBitRateKey: 128000
    ]
    compressionEncoder!.exportAsynchronously(completionHandler: {
    switch compressionEncoder!.status {
    case .completed:
    callback( [NSNull(), outputURL.absoluteString] )
    if saveToCameraRoll {
    UISaveVideoAtPathToSavedPhotosAlbum(outputURL.relativePath, self, nil, nil)
    }
    case .failed:
    callback( ["Failed: \(compressionEncoder!.error)", NSNull()] )
    
    case .cancelled:
    callback( ["Cancelled: \(compressionEncoder!.error)", NSNull()] )
    
    default: break
    }
    })
    }
    
    @objc func getAssetInfo(_ source: String, callback: RCTResponseSenderBlock) {
    let sourceURL = getSourceURL(source: source)
    let asset = AVAsset(url: sourceURL)
    var assetInfo: [String: Any] = [
    "duration" : asset.duration.seconds
    ]
    if let track = asset.tracks(withMediaType: AVMediaTypeVideo).first {
    let naturalSize = track.naturalSize
    let t = track.preferredTransform
    let isPortrait = t.a == 0 && abs(t.b) == 1 && t.d == 0
    let size = [
    "width": isPortrait ? naturalSize.height : naturalSize.width,
    "height": isPortrait ? naturalSize.width : naturalSize.height
    ]
    assetInfo["size"] = size
    }
    callback( [NSNull(), assetInfo] )
    }
    
    @objc func getPreviewImageAtPosition(_ source: String, atTime: Float = 0, maximumSize: NSDictionary, callback: RCTResponseSenderBlock) {
    let sourceURL = getSourceURL(source: source)
    let asset = AVAsset(url: sourceURL)
    
    var width: CGFloat = 1080
    if let _width = maximumSize.object(forKey: "width") as? CGFloat {
    width = _width
    }
    var height: CGFloat = 1080
    if let _height = maximumSize.object(forKey: "height") as? CGFloat {
    height = _height
    }
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.maximumSize = CGSize(width: width, height: height)
    imageGenerator.appliesPreferredTrackTransform = true
    var second = atTime
    if atTime > Float(asset.duration.seconds) || atTime < 0 {
    second = 0
    }
    let timestamp = CMTime(seconds: Double(second), preferredTimescale: 600)
    do {
      let imageRef = try imageGenerator.copyCGImage(at: timestamp, actualTime: nil)
      let image = UIImage(cgImage: imageRef)
      let imgData = UIImageJPEGRepresentation(image, 1.0)
      
      let fileName = ProcessInfo.processInfo.globallyUniqueString
      let fullPath = "\(NSTemporaryDirectory())\(fileName).jpg"
      
      try imgData?.write(to: URL(fileURLWithPath: fullPath), options: .atomic)
      
      let imageWidth = imageRef.width
      let imageHeight = imageRef.height
      let imageFormattedData: [AnyHashable: Any] = ["uri": fullPath, "width": imageWidth, "height": imageHeight]
      
      callback( [NSNull(), imageFormattedData] )
      
      //let imgData = UIImagePNGRepresentation(image)
      //let base64string = imgData?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
      //if base64string != nil {
        //callback( [NSNull(), base64string!] )
      //} else {
        //callback( ["Unable to convert to base64)", NSNull()]  )
      //}
    } catch {
      callback( ["Failed to convert base64: \(error.localizedDescription)", NSNull()] )
    }
    }
    
    func randomString() -> String {
    let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString: NSMutableString = NSMutableString(capacity: 20)
    let s:String = "RNTrimmer-Temp-Video"
    for _ in 0...19 {
    randomString.appendFormat("%C", letters.character(at: Int(arc4random_uniform(UInt32(letters.length)))))
    }
    return s.appending(randomString as String)
    }
    
    func getSourceURL(source: String) -> URL {
    var sourceURL: URL
    if source.contains("assets-library") {
    sourceURL = NSURL(string: source) as! URL
    } else {
    let bundleUrl = Bundle.main.resourceURL!
    sourceURL = URL(string: source, relativeTo: bundleUrl)!
    }
    return sourceURL
    }
    
    func getQualityForAsset(quality: String, asset: AVAsset) -> String {
    var useQuality: String
    
    switch quality {
    case QUALITY_ENUM.QUALITY_LOW.rawValue:
    useQuality = AVAssetExportPresetLowQuality
    
    case QUALITY_ENUM.QUALITY_MEDIUM.rawValue:
    useQuality = AVAssetExportPresetMediumQuality
    
    case QUALITY_ENUM.QUALITY_HIGHEST.rawValue:
    useQuality = AVAssetExportPresetHighestQuality
    
    case QUALITY_ENUM.QUALITY_640x480.rawValue:
    useQuality = AVAssetExportPreset640x480
    
    case QUALITY_ENUM.QUALITY_960x540.rawValue:
    useQuality = AVAssetExportPreset960x540
    
    case QUALITY_ENUM.QUALITY_1280x720.rawValue:
    useQuality = AVAssetExportPreset1280x720
    
    case QUALITY_ENUM.QUALITY_1920x1080.rawValue:
    useQuality = AVAssetExportPreset1920x1080
    
    case QUALITY_ENUM.QUALITY_3840x2160.rawValue:
    if #available(iOS 9.0, *) {
    useQuality = AVAssetExportPreset3840x2160
    } else {
    useQuality = AVAssetExportPresetPassthrough
    }
    
    default:
    useQuality = AVAssetExportPresetPassthrough
    }
    
    let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
    if !compatiblePresets.contains(useQuality) {
    useQuality = AVAssetExportPresetPassthrough
    }
    return useQuality
    }
}
