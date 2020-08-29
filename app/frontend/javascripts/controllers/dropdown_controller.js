import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['list'];

  show() {
    this.listTarget.classList.remove('u-display-none');
    App.dismissOnClick(this.listTarget);
  }
}
