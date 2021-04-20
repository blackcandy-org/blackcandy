import { Controller } from 'stimulus';

export default class extends Controller {
  static values = {
    isShown: Boolean
  }

  initialize() {
    if (this.isShownValue) {
      this.show();
    } else {
      this.hide();
    }
  }

  connect() {
    this.element.addEventListener('dialog:hide', this.hide);
    this.element.addEventListener('dialog:show', this.show);
  }

  disconnect() {
    this.element.removeEventListener('dialog:hide', this.hide);
    this.element.removeEventListener('dialog:show', this.show);
  }

  show = () => {
    document.querySelector('#js-overlay').classList.remove('u-display-none');
    this.element.classList.remove('u-display-none');
  }

  hide = () => {
    document.querySelector('#js-overlay').classList.add('u-display-none');
    this.element.classList.add('u-display-none');
  }
}
