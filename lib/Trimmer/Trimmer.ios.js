import React, { PropTypes, Component } from 'react';
import { requireNativeComponent, processColor } from 'react-native';
import { getActualSource } from '../utils';
const TRIMMER_COMPONENT_NAME = 'RNTrimmerView';

export class Trimmer extends Component {
  static propTypes = {
    source: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    width: PropTypes.number,
    height: PropTypes.number,
    themeColor: PropTypes.string,
    onChange: PropTypes.func,
    onTrackerMove: PropTypes.func,
    minLength: PropTypes.number,
    maxLength: PropTypes.number,
    currentTime: PropTypes.number,
    trackerColor: PropTypes.string
  };

  static defaultProps = {
    themeColor: 'gray',
    trackerColor: 'black'
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
      trackerColor
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
        onTrackerMove={this._handleTrackerMove}
        pointerEvents={'box-none'}
        onChange={this._onChange}
        minLength={minLength}
        maxLength={maxLength}
      />
    );
  }
}

const RNTrimmer = requireNativeComponent(TRIMMER_COMPONENT_NAME, Trimmer);
