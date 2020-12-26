import { Controller } from 'stimulus';

export default class extends Controller {
  static values = {
    timeout: Number
  }

  connect() {
    setTimeout(this._removeFlash.bind(this), this.timeoutValue);
  }

  _removeFlash() {
    this.element.addEventListener('animationend', function removeFlashElement() {
      this.remove();
    }, { once: true });

    this.element.classList.add('o-animation-fadeOutUp');
  }
}
