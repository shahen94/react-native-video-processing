import resolveAsset from 'react-native/Libraries/Image/resolveAssetSource';

export function getActualSource(source) {
	if (typeof source === 'number') {
		return resolveAsset(source).uri;
	}
	return source;
}
