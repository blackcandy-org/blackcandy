function formatDuration(secs) {
  const minutes = Math.floor(secs / 60) || 0;
  const seconds = (secs - (minutes * 60)) || 0;

  return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
}

function toggleVisible(elements, currentElement) {
  elements.forEach((element) => {
    element.classList.toggle('hidden', element == currentElement);
  });
}

export { formatDuration, toggleVisible };
