/* global expect */
import { getActualSource } from '../utils';

describe('[Utils]', () => {
	describe('[getActualSource]', () => {
		it('should be defined', () => {
			expect(getActualSource).toBeInstanceOf(Function);
		});
		it('using assets path, should return string', () => {
			const PATH_TO_SORUCE = 'pathToSource';
			const returnValue = getActualSource(PATH_TO_SORUCE);

			expect(returnValue).toBe(PATH_TO_SORUCE);
		});
		it('using require(),  should return string', () => {
			const returnValue = getActualSource(require('../../../test.jpeg'));
			expect(returnValue).toMatch(/assets/);
		});
	});
});
