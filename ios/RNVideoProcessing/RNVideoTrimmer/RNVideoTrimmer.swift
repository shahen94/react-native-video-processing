//
//  RNVideoTrimmer.swift
//  RNVideoProcessing
//

import Foundation
import AVFoundation

@objc(RNVideoTrimmer)
class RNVideoTrimmer: NSObject {

  @objc func trim(_ source: String, startTime: Float, endTime: Float, callback: @escaping RCTResponseSenderBlock) {

    let manager = FileManager.default
    guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      else {
        callback(["Error creating FileManager", NSNull()])
        return
    }

    let sourceURL = getSourceURL(source: source)
    let asset = AVAsset(url: sourceURL as URL)

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

    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
      else {
        callback(["Error creating AVAssetExportSession", NSNull()])
        return
    }
    exportSession.outputURL = NSURL.fileURL(withPath: outputURL.path)
    exportSession.outputFileType = AVFileTypeMPEG4

    let startTime = CMTime(seconds: Double(startTime), preferredTimescale: 1000)
    let endTime = CMTime(seconds: Double(endTime), preferredTimescale: 1000)
    let timeRange = CMTimeRange(start: startTime, end: endTime)

    exportSession.timeRange = timeRange
    exportSession.exportAsynchronously{
      switch exportSession.status {
      case .completed:
        callback( [NSNull(), outputURL.absoluteString] )
        UISaveVideoAtPathToSavedPhotosAlbum(outputURL.relativePath, self, nil, nil)

      case .failed:
        callback( ["Failed: \(exportSession.error?.localizedDescription)", NSNull()] )

      case .cancelled:
        callback( ["Cancelled: \(exportSession.error?.localizedDescription)", NSNull()] )

      default: break
      }
    }
  }

  @objc func getAssetInfo(_ source: String, callback: RCTResponseSenderBlock) {
    let sourceURL = getSourceURL(source: source)
    let asset = AVAsset(url: sourceURL)
    let assetInfo = [
      "duration" : asset.duration.seconds
    ]
    callback( [NSNull(), assetInfo] )
  }

  @objc func getPreviewImageAtPosition(_ source: String, atTime: Float = 0, callback: RCTResponseSenderBlock) {
    let sourceURL = getSourceURL(source: source)
    let asset = AVAsset(url: sourceURL)

    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    var second = atTime
    if atTime > Float(asset.duration.seconds) || atTime < 0 {
      second = 0
    }
    let timestamp = CMTime(seconds: Double(second), preferredTimescale: 60)
    do {
      let imageRef = try imageGenerator.copyCGImage(at: timestamp, actualTime: nil)
      let image = UIImage(cgImage: imageRef)
      let imgData = UIImagePNGRepresentation(image)
      let base64string = imgData?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
      if base64string != nil {
        callback( [NSNull(), base64string!] )
      } else {
        callback( ["Unable to convert to base64)", NSNull()]  )
      }
    } catch {
      callback( ["Failed to convert base64: \(error.localizedDescription)", NSNull()] )
    }
  }

  func randomString() -> String {
    let rand = 2 + Int(arc4random()) % 20
    let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var c = charSet.characters.map { String($0) }
    var s:String = "RNTrimmer-Temp-Video"
    for _ in (1...rand) {
        s.append(c[Int(arc4random()) % c.count])
    }
    return s
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
}
