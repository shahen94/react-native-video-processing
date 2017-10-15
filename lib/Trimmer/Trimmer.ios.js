import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { requireNativeComponent, processColor } from 'react-native';
import { getActualSource } from '../utils';
const TRIMMER_COMPONENT_NAME = 'RNTrimmerView';

export class Trimmer extends Component {
  static propTypes = {
    source: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    width: PropTypes.number,
    height: PropTypes.number,
    showTrackerHandle: PropTypes.bool,
    trackerHandleColor: PropTypes.string,
    themeColor: PropTypes.string,
    onChange: PropTypes.func,
    onTrackerMove: PropTypes.func,
    minLength: PropTypes.number,
    maxLength: PropTypes.number,
    currentTime: PropTypes.number,
    trackerColor: PropTypes.string,
    thumbWidth: PropTypes.number,
    borderWidth: PropTypes.number,
  };

  static defaultProps = {
    themeColor: 'gray',
    trackerColor: 'black',
    trackerHandleColor: 'gray',
    showTrackerHandle: false
  };

  constructor(...args) {
    super(...args);
    this.state = {};
    this._onChange = this._onChange.bind(this);
    this._handleTrackerMove = this._handleTrackerMove.bind(this);
  }

  _onChange(event) {
    if (!this.props.onChange) {
      return;
    }
    this.props.onChange(event.nativeEvent);
  }

  _handleTrackerMove({ nativeEvent }) {
    const { onTrackerMove } = this.props;
    const { currentTime } = nativeEvent;
    if (typeof onTrackerMove === 'function') {
      onTrackerMove({ currentTime });
    }
  }

  render() {
    const {
      source,
      width,
      height,
      themeColor,
      minLength,
      maxLength,
      currentTime,
      trackerColor,
      thumbWidth,
      borderWidth,
      showTrackerHandle,
      trackerHandleColor
    } = this.props;
    const actualSource = getActualSource(source);
    return (
      <RNTrimmer
        source={actualSource}
        width={width}
        height={height}
        currentTime={currentTime}
        themeColor={processColor(themeColor).toString()}
        trackerColor={processColor(trackerColor).toString()}
        showTrackerHandle={showTrackerHandle}
        trackerHandleColor={processColor(trackerHandleColor).toString()}
        onTrackerMove={this._handleTrackerMove}
        pointerEvents={'box-none'}
        onChange={this._onChange}
        minLength={minLength}
        maxLength={maxLength}
        thumbWidth={thumbWidth}
        borderWidth={borderWidth}
      />
    );
  }
}

const RNTrimmer = requireNativeComponent(TRIMMER_COMPONENT_NAME, Trimmer);
