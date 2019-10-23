// @flow

export type trimQuality = 'low'
  | 'medium'
  | 'highest'
  | '640x480'
  | '960x540'
  | '1280x720'
  | '1920x1080'
  | '3840x2160'
  | 'passthrough'
  ;

export type trimOptions = {
  startTime: ?number,
  endTime: ?number,
  quality: ?trimQuality,
  cameraType: ?string || 'back' //'back' or 'front'
};

export type sourceType = string
  | { uri: string };

export type previewMaxSize = {
  width: number,
  height: number
};

export type compressOptions = {
  bitrateMultiplier: number,
  height: number,
  width: number,
  minimumBitrate: number
};

export type format = 'base64' | 'JPEG';

export type cropOptions = {
  cropOffsetX: number,
  cropOffsetY: number,
  cropWidth: number,
  cropHeight: number,

  // TODO: TRIM IN CROP
  // startTime: ?String,
  // endTime: ?String,

  quality: ?trimQuality
};

type processingCallback = Function;

declare class RNVideoTrimmer {
  static trim(source: string, options: trimOptions, callback: processingCallback): void;
  static compress(source: string, options: compressOptions, callback: processingCallback): void;
  static getAssetInfo(source: string, callback: processingCallback): void;
  static getPreviewImageAtPosition(source: string, forSecond: number, maximumSize: previewMaxSize, callback: processingCallback): void;
  static getTrimmerPreviewImages(source: string, startTime: number, endTime: number, step: number, maximumSize: previewMaxSize): Promise<*>;
  static crop(source: string, options: cropOptions): Promise<{ source: string }>;
}
