import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['list'];

  show() {
    this.listTarget.classList.remove('u-display-none');
    document.addEventListener('click', this.close.bind(this), { once: true, capture: true });
  }

  close() {
    this.listTarget.classList.add('u-display-none');
  }
}
