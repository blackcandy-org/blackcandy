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

  submit (e) {
    this.inputTarget.value = this.inputTarget.value.trim()

    if (this.inputTarget.value.length === 0) {
      e.preventDefault()
      e.stopPropagation()
    } else {
      this.element.classList.add('is-loading')
    }
  }
}
