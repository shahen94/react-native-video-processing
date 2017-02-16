import React, { Component, PropTypes } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  requireNativeComponent,
  CameraRoll,
  UIManager,
  findNodeHandle
} from 'react-native';

export class VideoPlayer extends Component {
  static propTypes = {
    ...View.propTypes,
    play: PropTypes.bool,
    replay: PropTypes.bool,
    volume: PropTypes.number,
    onVideoProgress: PropTypes.func,
    currentTime: PropTypes.number,
    endTime: PropTypes.number,
    startTime: PropTypes.number,
    progressEventDelay: PropTypes.number,
    source: PropTypes.string.isRequired
  };
  constructor(props) {
    super(props);

    this._receiveVideoInfo = this._receiveVideoInfo.bind(this);
    this._receivePreviewImage = this._receivePreviewImage.bind(this);
    this._receiveTrimmedSource = this._receiveTrimmedSource.bind(this);
    this.trim = this.trim.bind(this);
    this.getInfoPromisesResolves = [];
    this.getPreviewForSecondResolves = [];
    this.trimResolves = [];
  }
  getVideoInfo() {
    UIManager.dispatchViewManagerCommand(
        findNodeHandle(this),
        UIManager.RNVideoProcessing.Commands.getInfo,
        [],
    );
    return new Promise((resolve) => {
      this.getInfoPromisesResolves.push(resolve);
    });
  }

  trim({ startTime, endTime }) {
    UIManager.dispatchViewManagerCommand(
        findNodeHandle(this),
        UIManager.RNVideoProcessing.Commands.trim,
        [startTime, endTime],
    );
    return new Promise((resolve) => {
      this.trimResolves.push(resolve);
    });
  }

  getPreviewForSecond(forSecond = 0) {
    UIManager.dispatchViewManagerCommand(
        findNodeHandle(this),
        UIManager.RNVideoProcessing.Commands.getPreviewForSecond,
        [forSecond],
    );
    return new Promise((resolve) => {
      this.getPreviewForSecondResolves.push(resolve);
    });
  }

  _receiveTrimmedSource(e) {
    this.trimResolves.forEach((resolve) => resolve(e.nativeEvent));
    this.trimResolves = [];
  }

  _receiveVideoInfo({ nativeEvent }) {
    this.getInfoPromisesResolves.forEach((resolve) => resolve(nativeEvent));
    this.getInfoPromisesResolves = [];
    debugger;
  }

  _receivePreviewImage({ nativeEvent }) {
    console.log(nativeEvent);
    this.getPreviewForSecondResolves.forEach((resolve) => resolve(nativeEvent))
    this.getPreviewForSecondResolves = [];
  }

  render() {
    console.log(UIManager.RNVideoProcessing);
    const {
      source,
      play,
      onVideoProgress,
      currentTime,
      endTime,
      startTime,
      replay,
      volume,
      style
    } = this.props;
    return (
      <RNVideoPlayer
        style={style}
        source={source}
        play={play}
        onVideoProgress={onVideoProgress}
        getVideoInfo={this._receiveVideoInfo}
        getPreviewImage={this._receivePreviewImage}
        getTrimmedSource={this._receiveTrimmedSource}
        currentTime={currentTime}
        endTime={endTime}
        startTime={startTime}
        replay={replay}
        volume={volume}
      />
    );
  }
}

const RNVideoPlayer = requireNativeComponent('RNVideoProcessing', VideoPlayer, {
  nativeOnly: {
    getVideoInfo: true,
    getPreviewImage: true,
    getTrimmedSource: true
  }
});
