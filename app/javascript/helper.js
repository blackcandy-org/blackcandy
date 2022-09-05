function formatDuration (secs) {
  const date = new Date(null)
  date.setSeconds(secs)
  const dateString = date.toISOString()

  return secs > 60 * 60 ? dateString.substring(11, 19) : dateString.substring(14, 19)
}

function shuffle (a) {
  for (let i = a.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

function randomIndex (length) {
  return Math.floor(Math.random() * (length - 1))
}

async function fetchRequest (url, options = {}) {
  const headers = {
    'Content-Type': 'application/json'
  }

  options.headers = ('headers' in options)
    ? { ...options.headers, ...headers }
    : headers

  const request = new Request(url, options)

  if (request.method !== 'GET') {
    options.headers['X-CSRF-Token'] = document.head.querySelector("[name='csrf-token']").content
  }

  return fetch(request, options)
}

function dispatchEvent (element, type, data = null) {
  if (typeof element === 'string') { element = document.querySelector(element) }
  element.dispatchEvent(new CustomEvent(type, { detail: data }))
}

export {
  formatDuration,
  shuffle,
  randomIndex,
  fetchRequest,
  dispatchEvent
}
