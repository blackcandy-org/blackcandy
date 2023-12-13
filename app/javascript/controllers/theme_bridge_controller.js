import { Controller } from '@hotwired/stimulus'
import { isNativeApp } from '../helper'

export default class extends Controller {
  static get shouldLoad () {
    return isNativeApp()
  }

  initialize () {
    App.nativeBridge.updateTheme(this.element.content)
  }
}
