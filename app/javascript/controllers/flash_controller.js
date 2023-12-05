import { Controller } from '@hotwired/stimulus'
import { isNativeApp } from '../helper'

export default class extends Controller {
  static get shouldLoad () {
    return !isNativeApp()
  }

  static values = {
    timeout: { type: Number, default: 4000 }
  }

  connect () {
    setTimeout(this.#removeFlash.bind(this), this.timeoutValue)
  }

  #removeFlash () {
    this.element.addEventListener('animationend', function removeFlashElement () {
      this.remove()
    }, { once: true })

    this.element.classList.add('o-animation-fadeOutUp')
  }
}
