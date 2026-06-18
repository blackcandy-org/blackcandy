import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'

const DIALOG_PARAM = 'dialog'

export default class extends Controller {
  initialize () {
    installEventHandler(this)

    if (this.hasDialogParam) {
      this.element.showModal()
    }
  }

  connect () {
    this.handleEvent('close', { on: this.element, with: this.onClose })
    this.handleEvent('popstate', { on: window, with: this.onPopstate })
  }

  hide () {
    this.element.close()
  }

  onClose = () => {
    const url = new URL(window.location)
    if (!url.searchParams.has(DIALOG_PARAM)) return

    url.searchParams.delete(DIALOG_PARAM)
    window.history.replaceState({}, '', url)
  }

  onPopstate = () => {
    if (!this.hasDialogParam && this.element.open) {
      this.hide()
    }
  }

  get hasDialogParam () {
    return new URL(window.location).searchParams.has(DIALOG_PARAM)
  }
}
