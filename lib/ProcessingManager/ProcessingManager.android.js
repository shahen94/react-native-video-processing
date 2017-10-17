// @flow

import { NativeModules } from 'react-native';
import type {
  sourceType,
  trimOptions,
  previewMaxSize,
  format,
  cropOptions
} from './types';

import { getActualSource } from '../utils';

const { RNTrimmerManager: TrimmerManager } = NativeModules;
export class ProcessingManager {
  static trim(source: sourceType, options: trimOptions): Promise<string> {
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

  static getVideoInfo(source: sourceType): Promise<*> {
    const actualSource: string = getActualSource(source);
    return TrimmerManager.getVideoInfo(actualSource);
  }

  static compress(source: sourceType, options: any): Promise<*> {
    const actualSource: string = getActualSource(source);
    return TrimmerManager.compress(actualSource, options);
  }

  static crop(source: sourceType, options: cropOptions): Promise<string> {
    const actualSource: string = getActualSource(source);
    return TrimmerManager.crop(actualSource, options)
      .then((res) => res.source);
  }

}
