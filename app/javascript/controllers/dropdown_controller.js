import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  static targets = ['menu']

  initialize () {
    installEventHandler(this)
  }

  connect () {
    this.handleEvent('click', {
      on: this.menuTarget,
      with: this.#close
    })
  }

  #close = () => {
    this.element.removeAttribute('open')
  }
}
