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

    var sourceURL: URL
    if source.contains("assets-library") {
        sourceURL = NSURL(string: source) as! URL
    } else {
        let bundleUrl = Bundle.main.resourceURL!
        sourceURL = URL(string: source, relativeTo: bundleUrl)!
    }
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
}
