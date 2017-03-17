// @flow

import { NativeModules } from 'react-native';
import type {
  sourceType,
  trimOptions
} from './types';

import { getActualSource } from '../utils';

const { RNTrimmerManager: TrimmerManager } = NativeModules;
class ProcessingManager {
  static trim(source: sourceType, options: trimOptions): Promise<string> {
    const actualSource: string = getActualSource(source);
    const mData = { source: actualSource, ...options };
    return TrimmerManager.trim(mData)
      .then((res) => res.source);
  }
  static compress(source: sourceType, options: any): Promise<*> {
    const actualSource: string = getActualSource(source);
    const mData = { source: actualSource, ...options };
    return TrimmerManager.compress(mData);
  }
  static getVideoInfo(source: sourceType): Promise<*> {
    const actualSource: string = getActualSource(source);
    return TrimmerManager.getVideoInfo(actualSource)
      .then(({ duration, size }) => ({
        duration: duration / 1000,
        size
      }));
  }
  static getPreviewForSecond(source: sourceType, second: number): Promise<*> {
    const actualSource: string = getActualSource(source);
    const mData = { source: actualSource, second };
    return TrimmerManager.getPreviewImageAtPosition(mData)
      .then((res) => res.image);
  }
}

export default ProcessingManager;
