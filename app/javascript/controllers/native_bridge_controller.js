import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  playAll (event) {
    if (!event.detail.success) { return }

    if (App.nativeBridge.isTurboNative) {
      App.nativeBridge.playAll()
    }
  }
}
