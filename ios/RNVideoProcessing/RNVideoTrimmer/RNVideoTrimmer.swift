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

        let startTime = CMTime(seconds: Double(sTime!), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(eTime!), preferredTimescale: 1000)
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
        var assetInfo: [String: Any] = [
            "duration" : asset.duration.seconds
        ]
        if let track = asset.tracks(withMediaType: AVMediaTypeVideo).first {
            let naturalSize = track.naturalSize
            let size = ["width": naturalSize.width, "height": naturalSize.height]
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
