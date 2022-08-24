import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  initialize () {
    this.element.showModal()
  }

  hide () {
    this.element.close()
  }
}
