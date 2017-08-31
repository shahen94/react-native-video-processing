jest.mock('../ProcessingManager.ios', () => {
	const ProcessingManager = {
		trim: jest.fn(),
		getPreviewForSecond: jest.fn(),
		compress: jest.fn()
	};
	return ProcessingManager;
});

import ProcessingManager from '../ProcessingManager.ios';

describe('[ProcessingManager]', () => {
	it('should be defined', () => {
		expect(ProcessingManager).toBeDefined();
	});
	it('should call trim', () => {
		ProcessingManager.trim();
		expect(ProcessingManager.trim).toHaveBeenCalled();
	});
	it('should call compress', () => {
		ProcessingManager.compress();
		expect(ProcessingManager.compress).toHaveBeenCalled();
	});
})
