import React, { PropTypes, Component } from 'react';
import {
	View,
	requireNativeComponent,
} from 'react-native';
import resolveAsset from 'react-native/Libraries/Image/resolveAssetSource';
const PLAYER_COMPONENT_NAME = 'RNVideoProcessing';

export class VideoPlayer extends Component {
	static propTypes = {
		source: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
		play: PropTypes.bool,
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
		volume: 0.0,
		currentTime: 0,
		startTime: 0,
	};
	constructor(...args) {
		super(...args);
		this.state = {};
	}

	render() {
		const {
			source,
			play,
			currentTime,
			backgroundColor,
			startTime,
			endTime,
      playerWidth,
      playerHeight,
			volume,
			...viewProps
		} = this.props;

		let actualSource = source;
		if (typeof source === 'number') {
			actualSource = resolveAsset(source).uri;
		}
		return (
			<RNVideoPlayer
				source={source}
				play={play}
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
