import '@hotwired/turbo-rails'
// TODO: Drop this dependency for Turbo's own exported morph once it ships.
// See https://github.com/hotwired/turbo/pull/1438
import { Idiomorph } from 'idiomorph'
import './controllers'

import Player from './player'

window.App = {
  player: new Player()
}

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
      Idiomorph.morph(appContainer, newAppContainer)
    } else {
      Idiomorph.morph(currentElement, newElement)
    }
  }
})
