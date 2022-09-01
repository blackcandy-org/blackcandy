import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  replaceWithChildren ({ target }) {
    this.element.replaceWith(...target.children)
  }
}
