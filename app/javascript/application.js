import '@hotwired/turbo-rails'
import './controllers'
import './channels'

import Player from './player'
import NativeBridge from './native_bridge'

window.App = {
  player: new Player(),
  nativeBridge: new NativeBridge()
}

App.nativeBridge.updateTheme(document.body.dataset.colorScheme)

// Use custom rendering to avoid reloading the permanent aside player element.
// Otherwise the current playlist controller in the aside player will be reconnected every time.
// And this will lead to unexpected behaviour when updating the current playlist song based on
// song element in the DOM.
window.addEventListener('turbo:before-render', ({ detail }) => {
  detail.render = async (currentElement, newElement) => {
    // This is a temporary fix for wrong page displayed when returning to the previous page.
    // See https://github.com/hotwired/turbo/issues/951. Remove this when the issue is fixed.
    await new Promise((resolve) => setTimeout(() => resolve(), 0))

    const appContainer = currentElement.querySelector('#js-app')
    const newAppContainer = newElement.querySelector('#js-app')

    if (appContainer && newAppContainer) {
      appContainer.replaceWith(newAppContainer)
    } else {
      document.body.replaceWith(newElement)
    }
  }
})
