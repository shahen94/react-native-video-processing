// @flow

import { NativeModules } from 'react-native';
import type {
  sourceType,
  arrayType,
  trimOptions,
  previewMaxSize,
  format,
  cropOptions
} from './types';

import { getActualSource, numberToHHMMSS } from '../utils';

const { RNTrimmerManager: TrimmerManager } = NativeModules;
export class ProcessingManager {
  static trim(source: sourceType, options: trimOptions): Promise<string> {
    if ( options.startTime != null ) {
      options.startTime = numberToHHMMSS({ number: options.startTime })
    }
    if ( options.endTime != null ) {
      options.endTime = numberToHHMMSS({ number: options.endTime })
    }

    const actualSource: string = getActualSource(source);
    const mData = { source: actualSource, ...options };
    return TrimmerManager.trim(mData)
      .then((res) => res.source);
  }

  static getPreviewForSecond(
    source: sourceType,
    second: number,
    maximumSize: previewMaxSize,
    format: format
  ): Promise<*> {
    const actualSource: string = getActualSource(source);
    const mData = { source: actualSource, second, format };
    return TrimmerManager.getPreviewImageAtPosition(mData)
      .then((res) => res.image);
  }

  static getTrimmerPreviewImages(
    source: sourceType, 
    startTime: number, 
    endTime: number, 
    step: number, 
    maximumSize: previewMaxSize, 
    format: fromat
  ): Promise<*> {
    const actualSource: string = getActualSource(source)
    const mData = { 
      source: actualSource, 
      startTime, 
      endTime, 
      step, 
      format
    }

    return TrimmerManager.getTrimmerPreviewImages(mData).then((res)=> res.images)
  }



  static getVideoInfo(source: sourceType): Promise<*> {
    const actualSource: string = getActualSource(source);
    return TrimmerManager.getVideoInfo(actualSource);
  }

  static compress(source: sourceType, options: any): Promise<*> {
    const actualSource: string = getActualSource(source);
    return TrimmerManager.compress(actualSource, options);
  }

  static boomerang(source: sourceType): Promise<*> {
    const actualSource: string = getActualSource(source);
    return TrimmerManager.boomerang(actualSource)
      .then((res) => res.source);
  }

  static reverse(source: sourceType): Promise<*> {
    const actualSource: string = getActualSource(source);
    return TrimmerManager.reverse(actualSource)
      .then((res) => res.source);
  }

  static crop(source: sourceType, options: cropOptions): Promise<string> {
    if ( options.startTime != null ) {
      options.startTime = numberToHHMMSS({ number: options.startTime })
    }
    if ( options.endTime != null ) {
      options.endTime = numberToHHMMSS({ number: options.endTime })
    }

    const actualSource: string = getActualSource(source);
    return TrimmerManager.crop(actualSource, options)
      .then((res) => res.source);
  }

  static merge(readableFiles: arrayType, cmd: string): Promise<string> {
    return TrimmerManager.merge(readableFiles, cmd).then((res) => res.source);
  }

}
