/* global expect */
import { calculateCornerResult, msToSec, numberToHHMMSS } from '../trimmer';

describe('[Trimmer Util]', () => {
	describe('[msToSec]', () => {
		it('should convert milisecond to second', () => {
			const milisecond = 1000000;
			const second = msToSec(milisecond);
			expect(second).toBe(milisecond / 1000);
		});
	});
	describe('[calculateCornerResult]', () => {
		it('should calculate corner result from left', () => {
			const duration1 = 1000;
			const value1 = 30;
			const width1 = 500;
			const result1 = calculateCornerResult(duration1, value1, width1);

			expect(result1).toEqual(60);

			const duration2 = 3400;
			const value2 = 200;
			const width2 = 400;
			const result2 = calculateCornerResult(duration2, value2, width2);

			expect(result2).toEqual(1700);
		});
		it('should calculate corner result from right', () => {
			const duration1 = 1000;
			const value1 = 30;
			const width1 = 500;
			const result1 = calculateCornerResult(duration1, value1, width1, true);

			expect(result1).toEqual(1000 - 60);

			const duration2 = 3400;
			const value2 = 200;
			const width2 = 400;
			const result2 = calculateCornerResult(duration2, value2, width2, true);

			expect(result2).toEqual(3400 - 1700);
		});

    it('should convert float to string for ffmpeg with numberToHHMMSS', () => {
			let startTime = 0.0;
			let endTime = 16.3;

      startTime = numberToHHMMSS({ number: startTime });
      endTime = numberToHHMMSS({ number: endTime });

      expect(startTime).toEqual( '00:00:00.000' );
			expect(endTime).toEqual( '00:00:16.300' );
		});
	});
});
