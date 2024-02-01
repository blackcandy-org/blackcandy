import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  static values = {
    defaultUrl: String
  }

  initialize () {
    installEventHandler(this)
  }

  connect () {
    if (!this.hasDefaultUrlValue) { return }

    this.handleEvent('error', {
      on: this.element,
      with: this.loadDefault
    })
  }

  loadDefault = () => {
    this.element.src = this.defaultUrlValue
  }
}
