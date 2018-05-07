function formatDuration(length) {
  const minutes = (length / 60) % 60;
  const seconds = length % 60;

  return [minutes, seconds].map((time) => {
    return Math.round(time).toString().padStart(2, '0');
  }).join(':');
}

export { formatDuration };
