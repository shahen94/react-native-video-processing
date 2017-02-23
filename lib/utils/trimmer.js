export function calculateCornerResult(duration, value, width, fromRight) {
  // duration -> width
  // x -> value
  // x = duration * value / width
  const val = Math.abs(value);
  const result = duration * val / width;
  return fromRight
    ? duration - result
    : result;
}

export function msToSec(ms) {
  return ms / 1000;
}
