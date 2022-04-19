import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  update (event) {
    if (!event.detail.success) { return }

    document.documentElement.setAttribute('data-color-scheme', this.theme)
  }

  select ({ params }) {
    this.theme = params.option
  }
}
