import { Controller } from '@hotwired/stimulus'
import { isNativeApp } from '../helper'

export default class extends Controller {
  static get shouldLoad () {
    return isNativeApp()
  }

  connect () {
    App.nativeBridge.showFlashMessage(this.element.textContent.trim())
  }
}
