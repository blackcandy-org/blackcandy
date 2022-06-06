import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['list']

  show () {
    this.listTarget.classList.remove('u-display-none')

    document.addEventListener('click', () => {
      this.listTarget.classList.add('u-display-none')
    }, { once: true, capture: true })
  }
}
