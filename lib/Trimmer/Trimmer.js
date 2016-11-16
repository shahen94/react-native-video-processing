import React, { PropTypes, Component } from 'react';
import { View, requireNativeComponent, DeviceEventEmitter, processColor } from 'react-native';

const TRIMMER_COMPONENT_NAME = 'RNTrimmerView';
const TRIM_EVENT = "VIDEO_PROCESSING_EVENT_TRIMMER";

export class Trimmer extends Component {
    static propTypes = {
      source: PropTypes.string.isRequired,
      width: PropTypes.number,
      height: PropTypes.number,
      themeColor: PropTypes.string,
      onChange: PropTypes.func
  };

  static defaultProps = {
      themeColor: 'gray'
  };

  constructor(...args) {
    super(...args);
    this.state = {};
    this.trimListener = null;
  }

  componentDidMount() {
      this.trimListener = DeviceEventEmitter.addListener(TRIM_EVENT, (event) => {
          if (typeof this.props.onChange === 'function') {
              this.props.onChange(event);
          }
      });
  }

  componentWillUnmount() {
      DeviceEventEmitter.removeListener(TRIM_EVENT, this.trimListener);
  }

  render() {
      const { source, width, height, themeColor } = this.props;
      return (
          <RNTrimmer
              source={source}
              width={width}
              height={height}
              themeColor={processColor(themeColor).toString()}
              pointerEvents={'box-none'}
          />
      );
  }
}

const RNTrimmer = requireNativeComponent(TRIMMER_COMPONENT_NAME, Trimmer);
