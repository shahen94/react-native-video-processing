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

export function numberToHHMMSS({ number }) {
  let sec_num = number;
  let hours   = Math.floor(sec_num / 3600);
  let minutes = Math.floor((sec_num - (hours * 3600)) / 60);
  let seconds = (sec_num - (hours * 3600) - (minutes * 60)).toFixed(3);

  if (hours   < 10) {hours   = "0"+hours;}
  if (minutes < 10) {minutes = "0"+minutes;}
  if (seconds < 10) {seconds = "0"+seconds;}
  return hours+':'+minutes+':'+seconds;
}
