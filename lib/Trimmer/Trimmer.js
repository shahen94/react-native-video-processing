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
		minLength: PropTypes.number,
		maxLength: PropTypes.number
	};

	static defaultProps = {
		themeColor: 'gray'
	};

	constructor(...args) {
		super(...args);
		this.state = {};
		this._onChange = this._onChange.bind(this);
	}

	_onChange(event) {
		if (!this.props.onChange) {
			return;
		}
		this.props.onChange(event.nativeEvent);
	}

	render() {
		const { source, width, height, themeColor, minLength, maxLength } = this.props;
		const actualSource = getActualSource(source);
		return (
			<RNTrimmer
				source={actualSource}
				width={width}
				height={height}
				themeColor={processColor(themeColor).toString()}
				pointerEvents={'box-none'}
				onChange={this._onChange}
				minLength={minLength}
				maxLength={maxLength}
			/>
		);
	}
}

const RNTrimmer = requireNativeComponent(TRIMMER_COMPONENT_NAME, Trimmer);
