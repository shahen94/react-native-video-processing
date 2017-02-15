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
    this.getInfoPromisesResolves = [];
    this.getPreviewForSecondResolves = [];
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
    getPreviewImage: true
  }
});
