import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input']

  connect () {
    this.moveCursorToEnd()
    this.element.classList.remove('is-loading')
  }

  moveCursorToEnd () {
    const searchValueLength = this.inputTarget.value.length
    if (searchValueLength > 0) {
      this.inputTarget.focus()
      this.inputTarget.setSelectionRange(searchValueLength, searchValueLength)
    }
  }

  // Runs on htmx:config:request. htmx has already taken the submit event,
  // so cancelling its request is what drops an empty search.
  submit (event) {
    const query = this.inputTarget.value.trim()

    if (query.length === 0) {
      event.preventDefault()
      return
    }

    this.inputTarget.value = query
    event.detail.ctx.request.body.set(this.inputTarget.name, query)
    this.element.classList.add('is-loading')
  }
}
