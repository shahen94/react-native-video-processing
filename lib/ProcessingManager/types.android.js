// @flow

export type sourceType = string
  | { uri: string };

export type trimOptions = {
  startTime: number,
  endTime: number
};

// TODO
export type previewMaxSize = {
  width: number,
  height: number
};

export type format = 'base64' | 'JPEG';

export type cropOptions = {
  cropOffsetX: number,
  cropOffsetY: number,
  cropWidth: number,
  cropHeight: number,

  startTime: ?number,
  endTime: ?number,

  // TODO: COMPRESS IN CROP
  // quality: ?trimQuality
};

export type arrayType = Array<string>;

declare class RNTrimmerManager {
  static trim(source: string, options: trimOptions): Promise<{ source: string }>;
  static compress(source: string, options: any): Promise<*>;
  static getVideoInfo(source: string): Promise<*>;
  static getPreviewImages(source: string): Promise<*>;
  static getPreviewImageAtPosition(source: string, second: number): Promise<{ image: string }>;
  static getTrimmerPreviewImages(source: string, startTime: number, endTime: number, step: number): Promise<Array<{ image: string }>>;
  static crop(source: string, options: cropOptions): Promise<{ source: string }>;
  static merge(source: arrayType, cmd: string): Promise<{ source: string }>;
}
