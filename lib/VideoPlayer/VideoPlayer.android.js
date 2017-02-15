import React, { PureComponent, PropTypes } from 'react';
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

export class VideoPlayer extends PureComponent {
  static propTypes = {
    ...View.propTypes,
    play: PropTypes.bool,
    replay: PropTypes.bool,
    volume: PropTypes.number,
    getVideoInfo: PropTypes.func,
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
    this.getInfoPromisesResolves = [];
  }
  getVideoInfo() {
    UIManager.dispatchViewManagerCommand(
        findNodeHandle(this),
        UIManager.RNVideoProcessing.Commands.getInfo,
        [],
    );
    return new Promise ((resolve) => {
      this.getInfoPromisesResolves.push(resolve);
    });
  }

  _receiveVideoInfo({ nativeEvent }) {
    this.getInfoPromisesResolves.forEach((resolve) => resolve(nativeEvent));
    this.getInfoPromisesResolves = [];
  }

  render() {
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
        currentTime={currentTime}
        endTime={endTime}
        startTime={startTime}
        replay={replay}
        volume={volume}
      />
    );
  }
}

const RNVideoPlayer = requireNativeComponent('RNVideoProcessing', VideoPlayer);
