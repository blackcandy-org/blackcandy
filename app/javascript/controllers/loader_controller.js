import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content', 'indicator']

  connect () {
    this.element.addEventListener('loader:hide', this.#hide)
    this.element.addEventListener('loader:show', this.#show)
  }

  disconnect () {
    this.element.removeEventListener('loader:hide', this.#hide)
    this.element.removeEventListener('loader:show', this.#show)
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
