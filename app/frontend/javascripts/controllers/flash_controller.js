import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    setTimeout(this._removeFlash.bind(this), this.data.get('timeout'));
  }

  _removeFlash() {
    this.element.addEventListener('animationend', function removeFlashElement() {
      this.remove();
    }, { once: true });

    this.element.classList.add('flash__body--close');
  }
}
