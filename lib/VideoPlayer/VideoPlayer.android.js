import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { noop } from 'lodash';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  requireNativeComponent,
  CameraRoll,
  UIManager,
  findNodeHandle,
  ViewPropTypes
} from 'react-native';
import { getActualSource } from '../utils';

const ProcessingUI = UIManager.getViewManagerConfig('RNVideoProcessing');

export class VideoPlayer extends Component {
  static Constants = {
    resizeMode: {
      CONTAIN: ProcessingUI.Constants.ScaleAspectFit,
      COVER: ProcessingUI.Constants.ScaleAspectFill,
      STRETCH: ProcessingUI.Constants.ScaleToFill,
      NONE: ProcessingUI.Constants.ScaleNone
    }
  };
  static propTypes = {
    ...ViewPropTypes,
    play: PropTypes.bool,
    replay: PropTypes.bool,
    volume: PropTypes.number,
    onChange: PropTypes.func,
    currentTime: PropTypes.number,
    endTime: PropTypes.number,
    startTime: PropTypes.number,
    progressEventDelay: PropTypes.number,
    source: PropTypes.string.isRequired,
    resizeMode: PropTypes.string
  };
  static defaultProps = {
    onChange: noop,
  };

  constructor(props) {
    super(props);
    this._receiveVideoInfo = this._receiveVideoInfo.bind(this);
    this._receivePreviewImage = this._receivePreviewImage.bind(this);
    this._receiveTrimmedSource = this._receiveTrimmedSource.bind(this);
    this._receiveCompressedSource = this._receiveCompressedSource.bind(this);
    this._onVideoProgress = this._onVideoProgress.bind(this);
    this.trim = this.trim.bind(this);
    this.compress = this.compress.bind(this);
    this.getInfoPromisesResolves = [];
    this.getPreviewForSecondResolves = [];
    this.trimResolves = [];
    this.compressResolves = [];
  }

  getVideoInfo() {
    if (!this.props.source) {
      console.warn('Video source is empty');
      return Promise.reject();
    }
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      ProcessingUI.Commands.getInfo,
      [],
    );
    return new Promise((resolve) => {
      this.getInfoPromisesResolves.push(resolve);
    });
  }

  trim(options) {
    if (typeof options === 'string') {
      console.warn('There is no need to pass source for trimming, this is deprecated and will be removed on the next version');
      return Promise.reject();
    }
    const { startTime, endTime } = options;
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      ProcessingUI.Commands.trim,
      [startTime, endTime],
    );
    return new Promise((resolve) => {
      this.trimResolves.push(resolve);
    });
  }

  compress(_options = {}) {
    const options = { ..._options };
    // const options = {
    //  height: 1080, // output video's height
    //  width: 720, // output video's width
    //  bitrateMultiplier: 10, // divide video's bitrate to this value
    //  minimumBitrate: 250000,
    //  removeAudio: true, //default is false
    // };
    if (options.hasOwnProperty('bitrateMultiplier') && options.bitrateMultiplier <= 0) {
      options.bitrateMultiplier = 1;
      // eslint-disable-next-line no-console
      console.warn('bitrateMultiplier cannot be less than zero');
    }
    if (options.hasOwnProperty('height') && options.height <= 0) {
      delete options.height;
      // eslint-disable-next-line no-console
      console.warn('height cannot be less than zero');
    }
    if (options.hasOwnProperty('width') && options.width <= 0) {
      delete options.width;
      // eslint-disable-next-line no-console
      console.warn('width cannot be less than zero');
    }
    if (options.hasOwnProperty('minimumBitrate') && options.minimumBitrate <= 0) {
      delete options.minimumBitrate;
      // eslint-disable-next-line no-console
      console.warn('minimumBitrate cannot be less than zero');
    }
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      ProcessingUI.Commands.compress,
      [options]
    );
    return new Promise((resolve) => {
      this.compressResolves.push(resolve);
    });
  }

  getPreviewForSecond(forSecond = 0) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      ProcessingUI.Commands.getPreviewForSecond,
      [forSecond],
    );
    return new Promise((resolve) => {
      this.getPreviewForSecondResolves.push(resolve);
    });
  }

  _receiveTrimmedSource(e) {
    this.trimResolves.forEach((resolve) => resolve(e.nativeEvent.source));
    this.trimResolves = [];
  }

  _receiveCompressedSource(e) {
    this.compressResolves.forEach((resolve) => resolve(e.nativeEvent.source));
    this.compressResolves = [];
  }

  _receiveVideoInfo({ nativeEvent }) {
    const event = {
      size: { width: nativeEvent.width, height: nativeEvent.height },
      duration: nativeEvent.duration
    };
    this.getInfoPromisesResolves.forEach((resolve) => resolve(event));
    this.getInfoPromisesResolves = [];
  }

  _receivePreviewImage({ nativeEvent }) {
    this.getPreviewForSecondResolves.forEach((resolve) => resolve(nativeEvent));
    this.getPreviewForSecondResolves = [];
  }

  _onVideoProgress(e) {
    if (typeof this.props.onChange === 'function') {
      this.props.onChange(e);
    }
  }

  render() {
    const {
      source,
      play,
      currentTime,
      endTime,
      startTime,
      replay,
      volume,
      style,
      resizeMode,
      ...props
    } = this.props;
    const mSource = getActualSource(source);

    if (__DEV__) {
      const isCompatible = Object
        .values(VideoPlayer.Constants.resizeMode)
        .includes(resizeMode);

      if (!isCompatible) {
        console.warn('Wrong resizeMode property, please use VideoPlayer.Constants.resizeMode constants');
      }
    }

    return (
      <RNVideoPlayer
        style={style}
        source={mSource}
        play={play}
        onVideoProgress={this._onVideoProgress}
        getVideoInfo={this._receiveVideoInfo}
        getPreviewImage={this._receivePreviewImage}
        getTrimmedSource={this._receiveTrimmedSource}
        getCompressedSource={this._receiveCompressedSource}
        currentTime={currentTime}
        endTime={endTime}
        startTime={startTime}
        replay={replay}
        resizeMode={resizeMode}
        volume={volume}
        {...props}
      />
    );
  }
}

const RNVideoPlayer = requireNativeComponent('RNVideoProcessing', VideoPlayer, {
  nativeOnly: {
    getVideoInfo: true,
    getPreviewImage: true,
    getTrimmedSource: true,
    onVideoProgress: true
  }
});
