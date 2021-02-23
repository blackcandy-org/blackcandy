function formatDuration(secs) {
  const date = new Date(null);
  date.setSeconds(secs);
  const dateString = date.toISOString();

  return secs > 60 * 60 ? dateString.substring(11, 19) : dateString.substring(14, 19);
}

function toggleShow(elements, currentElement) {
  elements.forEach((element) => {
    element.classList.toggle('u-display-none', element != currentElement);
  });
}

function shuffle(a) {
  for (let i = a.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function randomIndex(length) {
  return Math.floor(Math.random() * (length - 1));
}

async function fetchTurboStream(request, options = {}, successCallback = () => {}) {
  const turboStreamHeader = {
    Accept: 'text/vnd.turbo-stream.html'
  };

  options.headers = ('headers' in options) ?
    { ...options.headers, ...turboStreamHeader } :
    turboStreamHeader;

  try {
    const response = await fetch(request, options);

    if (response.ok) {
      const streamMessage = await response.text();

      Turbo.renderStreamMessage(streamMessage);
      successCallback();
    }
  } catch (_) { /* ignore error */ }
}

export {
  formatDuration,
  toggleShow,
  shuffle,
  randomIndex,
  fetchTurboStream
};
