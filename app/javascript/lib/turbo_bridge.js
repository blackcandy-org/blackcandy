// While Turbo is being replaced, htmx owns navigation and history, and Turbo
// keeps rendering the frames and streams that are still left. Delete this with Turbo.
import { Turbo } from '@hotwired/turbo-rails'
import htmx from 'htmx.org'

Turbo.session.drive = false

// Turbo still listens to popstate and rewrites entries that lack its marker,
// and htmx only restores entries marked { htmx: true }, starting with this one.
Turbo.session.history.stop()
window.history.replaceState({ htmx: true }, '', window.location.href)

// Turbo also switches scroll restoration to manual once the page has loaded.
window.addEventListener('load', () => { window.history.scrollRestoration = 'auto' })

// htmx doesn't watch the DOM. Hand it what Turbo renders into frames or
// streams in, so the _top links there are boosted.
new MutationObserver((records) => {
  for (const { addedNodes } of records) {
    for (const node of addedNodes) {
      if (node.nodeType === Node.ELEMENT_NODE) htmx.process(node)
    }
  }
}).observe(document.body, { childList: true, subtree: true })

// Forms that Rails still answers with Turbo Streams: ask for streams as Turbo
// did, and hand them to Turbo before htmx swaps anything or pushes a URL.
const STREAM = 'text/vnd.turbo-stream.html'

document.addEventListener('htmx:config:request', ({ detail: { ctx } }) => {
  if (ctx.request.method !== 'GET') ctx.request.headers.Accept = `${STREAM}, text/html`
})

document.addEventListener('htmx:after:request', (event) => {
  const { ctx } = event.detail
  if (!ctx.response.headers.get('Content-Type')?.startsWith(STREAM)) return

  event.preventDefault()
  Turbo.renderStreamMessage(ctx.text)
})

// Dialog links load a Turbo Frame. Push their URL as an htmx entry,
// where data-turbo-action="advance" pushed a Turbo one.
document.addEventListener('turbo:before-frame-render', ({ target }) => {
  if (target.id === 'turbo-dialog') window.history.pushState({ htmx: true }, '', target.src)
})

// A frame response without the frame, such as the login page once the session
// is revoked, would start a Turbo page visit. Load it in full instead.
document.addEventListener('turbo:frame-missing', (event) => {
  event.preventDefault()
  window.location.assign(event.detail.response.url)
})
