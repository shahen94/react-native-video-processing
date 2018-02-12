//
//  GPUImageFilters.swift
//  vpTest
//
//  Created by Shahen Hovhannisyan on 11/16/16.
//

import Foundation
import GPUImage

class VideoProcessingGPUFilters {
  let filters = [
    "saturation": GPUImageSaturationFilter(),
    "sepia": GPUImageSepiaFilter(),
    "pixelate": GPUImagePixellateFilter(),
    "hue": GPUImageHueFilter(),
    "vignette": GPUImageVignetteFilter(),
    "guassianBlur": GPUImageGaussianBlurFilter()
  ]

  // TODO: add more filters

  func getFilterByName(name: String) -> GPUImageFilter? {
    return filters[name]
  }

  func getAllFilters() -> [String: GPUImageFilter] {
    return filters
  }
}
