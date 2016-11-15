/* global expect, jest */

import React from 'react';
jest.mock('../VideoPlayer', () => 'VideoPlayer');
import VideoPlayer from '../VideoPlayer';
import renderer from 'react-test-renderer';

describe('VideoPlayer', () => {
	it('Should be defined', () => {
		expect(VideoPlayer).toBeDefined();
	});
	it('Should render correctly', () => {
		const mockRender = renderer.create(
			<VideoPlayer source={'somePath'} />
		);

		const jsonRenderedComponent = mockRender.toJSON();

		expect(jsonRenderedComponent).toMatchSnapshot();
	});
});
