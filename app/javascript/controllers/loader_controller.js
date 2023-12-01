import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  static targets = ['content', 'indicator']

  initialize () {
    installEventHandler(this)
  }

  connect () {
    this.handleEvent('loader:hide', {
      on: this.element,
      with: this.#hide
    })

    this.handleEvent('loader:show', {
      on: this.element,
      with: this.#show
    })
  }

  #show = () => {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add('u-display-none')
    }

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.remove('u-display-none')
    }
  }

  #hide = () => {
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove('u-display-none')
    }

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.add('u-display-none')
    }
  }
}
