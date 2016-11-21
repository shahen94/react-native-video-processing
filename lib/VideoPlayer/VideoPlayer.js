import React, { PropTypes, Component } from 'react';
import {
	View,
	requireNativeComponent,
	NativeModules
} from 'react-native';
import { getActualSource } from '../utils';
const PLAYER_COMPONENT_NAME = 'RNVideoProcessing';

const { RNVideoTrimmer } = NativeModules;

export class VideoPlayer extends Component {
	static propTypes = {
		source: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
		play: PropTypes.bool,
		replay: PropTypes.bool,
		currentTime: PropTypes.number,
		volume: PropTypes.number,
		startTime: PropTypes.number,
		background_Color: PropTypes.string,
		endTime: PropTypes.number,
		playerWidth: PropTypes.number,
		playerHeight: PropTypes.number,
		...View.propTypes
	};
	static defaultProps = {
		play: false,
		replay: false,
		volume: 0.0,
		currentTime: 0,
		startTime: 0,
	};
	constructor(...args) {
		super(...args);
		this.state = {};
		this.trim = this.trim.bind(this);
		this.getPreviewForSecond = this.getPreviewForSecond.bind(this);
	}

	getPreviewForSecond(source, forSecond = 0) {
		const actualSource = getActualSource(source);
		return new Promise((resolve, reject) => {
			RNVideoTrimmer.getPreviewImageAtPosition(actualSource, forSecond, (err, base64) => {
				if (err) {
					return reject(err);
				}
				return resolve(base64);
			});
		});
	}

	trim(source, start, end) {
		const actualSource = getActualSource(source);
		return new Promise((resolve, reject) => {
			RNVideoTrimmer.trim(actualSource, start, end, (err, output) => {
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
				volume={volume}
				playerWidth={playerWidth}
				playerHeight={playerHeight}
				currentTime={currentTime}
				background_Color={backgroundColor}
				startTime={startTime}
				endTime={endTime}
				{...viewProps}
			/>
		);
	}
}

const RNVideoPlayer = requireNativeComponent(PLAYER_COMPONENT_NAME, VideoPlayer);
