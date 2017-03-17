// @flow


import { NativeModules } from 'react-native';
import { getActualSource } from '../utils';
const { RNVideoTrimmer } = NativeModules;
import type {
  compressOptions,
  previewMaxSize,
  sourceType,
  trimOptions,
} from './types';

export class ProcessingManager {
  static trim(source: sourceType, options: trimOptions = {}) {
    const actualSource: string = getActualSource(source);
    return new Promise((resolve, reject) => {
      RNVideoTrimmer.trim(actualSource, options, (err: Object<*>, output: string) => {
        if (err) {
          return reject(err);
        }
        return resolve(output);
      });
    });
  };
  static getPreviewForSecond(
    source: sourceType,
    forSecond: ?number = 0,
    maximumSize: previewMaxSize
  ) {
    const actualSource: string = getActualSource(source);
    return new Promise((resolve, reject) => {
      RNVideoTrimmer.getPreviewImageAtPosition(actualSource, forSecond, maximumSize,
        (err: Object<*>, base64: string) => {
          if (err) {
            return reject(err);
          }
          return resolve(base64);
        });
    });
  }
  static getVideoInfo(source: sourceType) {
    const actualSource: string = getActualSource(source);
    return new Promise((resolve, reject) => {
      RNVideoTrimmer.getAssetInfo(actualSource, (err, info) => {
        if (err) {
          return reject(err);
        }
        return resolve(info);
      });
    });
  }
  static compress(source: sourceType, _options: compressOptions) {
    const options = { ..._options };
    const actualSource = getActualSource(source);
    return new Promise((resolve, reject) => {
      RNVideoTrimmer.compress(actualSource, options, (err, output) => {
        if (err) {
          return reject(err);
        }
        return resolve(output);
      });
    });
  }
}

export default ProcessingManager;
