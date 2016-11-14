import React, { PropTypes, Component } from 'react';
import { View, requireNativeComponent } from 'react-native';

const PLAYER_COMPONENT_NAME = 'RNVideoPlayer';

export class VideoPlayer extends Component {
	static propTypes = {
		source: PropTypes.string.isRequired,
		play: PropTypes.bool,
		startTime: PropTypes.number,
		currentTime: PropTypes.number,
		endTime: PropTypes.number,
		...View.propTypes
	};
	static defaultProps = {
		play: false,
		currentTime: 0,
		startTime: 0
	};
	constructor(...args) {
		super(...args);
		this.state = {};
	}
	render() {
		return (
			<View />
		);
	}
}

const RNVideoPlayer = requireNativeComponent(PLAYER_COMPONENT_NAME, VideoPlayer);
