function formatDuration(secs) {
  const minutes = Math.floor(secs / 60) || 0;
  const seconds = (secs - (minutes * 60)) || 0;

  return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
}

function toggleShow(elements, currentElement) {
  elements.forEach((element) => {
    element.classList.toggle('hidden', element != currentElement);
  });
}

function shuffle(a) {
  for (let i = a.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function dispatchEvent(element, type) {
  element.dispatchEvent(new Event(type));
}

export { formatDuration, toggleShow, shuffle, dispatchEvent };
