/* global expect, jest */
import React from 'react';
import renderer from 'react-test-renderer';

jest.mock('../Trimmer', () => {
  const React = require('react');
  const Component = React.Component;

  class Trimmer extends Component {
		render() {
			return React.createElement('View', this.props, null);
		}
	}

  return Trimmer;
});

import Trimmer from '../Trimmer';


describe('[Trimmer]', () => {
	it('should be defined', () => {
		expect(Trimmer).toBeDefined();
	});

	it('should be render correctly', () => {
		const mockedComonent = renderer.create(
			<Trimmer
				source={'someSourceGoeshere'}
				width={300}
				height={300}
				themeColor={'blue'}
				onChange={() => null}
			/>
		);

		expect(mockedComonent.toJSON()).toMatchSnapshot();
	});
});
