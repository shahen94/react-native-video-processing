import React, { PropTypes, Component } from 'react';
import {
	View,
	requireNativeComponent,
} from 'react-native';

const PLAYER_COMPONENT_NAME = 'RNVideoProcessing';

export class VideoPlayer extends Component {
	static propTypes = {
		source: PropTypes.string.isRequired,
		play: PropTypes.bool,
		currentTime: PropTypes.number,
		startTime: PropTypes.number,
		background_Color: PropTypes.string,
		endTime: PropTypes.number,
		playerWidth: PropTypes.number,
		playerHeight: PropTypes.number,
		...View.propTypes
	};
	static defaultProps = {
		play: false,
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
			...viewProps
		} = this.props;

		return (
			<RNVideoPlayer
				source={source}
				play={play}
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
