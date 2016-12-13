import React, { PropTypes, Component } from 'react';
import { View, requireNativeComponent, NativeModules } from 'react-native';
import { getActualSource } from '../utils';
const PLAYER_COMPONENT_NAME = 'RNVideoProcessing';

const { RNVideoTrimmer } = NativeModules;

export class VideoPlayer extends Component {
	static propTypes = {
		source: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
		play: PropTypes.bool,
		replay: PropTypes.bool,
		rotate: PropTypes.bool,
		currentTime: PropTypes.number,
		volume: PropTypes.number,
		startTime: PropTypes.number,
		background_Color: PropTypes.string,
		endTime: PropTypes.number,
		playerWidth: PropTypes.number,
		playerHeight: PropTypes.number,
		onChange: PropTypes.func,
		...View.propTypes
	};

	static defaultProps = {
		play: false,
		replay: false,
		rotate: false,
		volume: 0.0,
		currentTime: 0,
		startTime: 0,
	};

	static Constants = {
		quality: {
			QUALITY_LOW: 'low',
			QUALITY_MEDIUM: 'medium',
			QUALITY_HIGHEST: 'highest',
			QUALITY_640x480: '640x480',
			QUALITY_960x540: '960x540',
			QUALITY_1280x720: '1280x720',
			QUALITY_1920x1080: '1920x1080',
			QUALITY_3840x2160: '3840x2160', // available in iOS 9
			QUALITY_PASS_THROUGH: 'passthrough', // does not change quality
		}
	};

	constructor(...args) {
		super(...args);
		this.state = {};
		this.trim = this.trim.bind(this);
		this.getPreviewForSecond = this.getPreviewForSecond.bind(this);
		this.getVideoInfo = this.getVideoInfo.bind(this);
		this._onChange = this._onChange.bind(this);
	}

	getPreviewForSecond(source, forSecond = 0, maximumSize) {
		const actualSource = getActualSource(source);
		return new Promise((resolve, reject) => {
			RNVideoTrimmer.getPreviewImageAtPosition(actualSource, forSecond, maximumSize,
				(err, base64) => {
					if (err) {
						return reject(err);
					}
					return resolve(base64);
				});
		});
	}

	getVideoInfo(source) {
		const actualSource = getActualSource(source);
		return new Promise((resolve, reject) => {
			RNVideoTrimmer.getAssetInfo(actualSource, (err, info) => {
				if (err) {
					return reject(err);
				}
				return resolve(info);
			});
		});
	}

	_onChange(event) {
		if (!this.props.onChange) {
			return;
		}
		this.props.onChange(event);
	}

	trim(source, options = {}) {
		const availableQualities = Object.values(VideoPlayer.Constants.quality);
		if (!options.hasOwnProperty('startTime')) {
			// eslint-disable-next-line no-console
			console.warn('Start time is not specified');
		}
		if (!options.hasOwnProperty('endTime')) {
			// eslint-disable-next-line no-console
			console.warn('End time is not specified');
		}
		if (options.hasOwnProperty('quality') && !availableQualities.includes(options.quality)) {
			// eslint-disable-next-line no-console
			console.warn('Quality is wrong, Please use VideoPlayer.Constants.quality');
		}
		const actualSource = getActualSource(source);
		return new Promise((resolve, reject) => {
			RNVideoTrimmer.trim(actualSource, options, (err, output) => {
				if (err) {
					return reject(err);
				}
				return resolve(output);
			});
		});
	}

	render() {
		const {
			source,
			play,
			replay,
			rotate,
			currentTime,
			backgroundColor,
			startTime,
			endTime,
			playerWidth,
			playerHeight,
			volume,
			...viewProps
		} = this.props;

		const actualSource = getActualSource(source);
		return (
			<RNVideoPlayer
				source={actualSource}
				play={play}
				replay={replay}
				rotate={rotate}
				volume={volume}
				playerWidth={playerWidth}
				playerHeight={playerHeight}
				currentTime={currentTime}
				background_Color={backgroundColor}
				startTime={startTime}
				endTime={endTime}
				onChange={this._onChange}
				{...viewProps}
			/>
		);
	}
}

const RNVideoPlayer = requireNativeComponent(PLAYER_COMPONENT_NAME, VideoPlayer);
