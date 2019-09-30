/*
 * Credit to whydna and yayoc
 * https://github.com/whydna/Reverse-AVAsset-Efficient
 */

import UIKit
import AVFoundation

class AVUtilities {
  static func reverse(_ original: AVAsset, outputURL: URL, completion: @escaping (AVAsset) -> Void) {
    
    // Initialize the reader
    
    var reader: AVAssetReader! = nil
    do {
      reader = try AVAssetReader(asset: original)
    } catch {
      print("could not initialize reader.")
      return
    }
    
    guard let videoTrack = original.tracks(withMediaType: AVMediaTypeVideo).last else {
      print("could not retrieve the video track.")
      return
    }
    
    let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
    let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
    reader.add(readerOutput)
    
    reader.startReading()
    
    // read in samples
    
    var samples: [CMSampleBuffer] = []
    while let sample = readerOutput.copyNextSampleBuffer() {
      samples.append(sample)
    }
    
    // Initialize the writer
    
    let writer: AVAssetWriter
    do {
      writer = try AVAssetWriter(outputURL: outputURL, fileType: AVFileTypeQuickTimeMovie)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    
    let videoCompositionProps = [AVVideoAverageBitRateKey: videoTrack.estimatedDataRate]
    let writerOutputSettings = [
      AVVideoCodecKey: AVVideoCodecH264,
      AVVideoWidthKey: videoTrack.naturalSize.width,
      AVVideoHeightKey: videoTrack.naturalSize.height,
      AVVideoCompressionPropertiesKey: videoCompositionProps
      ] as [String : Any]
    
    let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: writerOutputSettings)
    writerInput.expectsMediaDataInRealTime = false
    writerInput.transform = videoTrack.preferredTransform
    
    let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
    
    writer.add(writerInput)
    writer.startWriting()
    writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(samples.first!))
    
    for (index, sample) in samples.enumerated() {
      let presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
      let imageBufferRef = CMSampleBufferGetImageBuffer(samples[samples.count - 1 - index])
      while !writerInput.isReadyForMoreMediaData {
        Thread.sleep(forTimeInterval: 0.1)
      }
      pixelBufferAdaptor.append(imageBufferRef!, withPresentationTime: presentationTime)
      
    }
    
    writer.finishWriting {
      completion(AVAsset(url: outputURL))
    }
  }
}


