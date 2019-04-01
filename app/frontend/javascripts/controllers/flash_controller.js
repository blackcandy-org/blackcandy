import { Controller } from 'stimulus';

export default class extends Controller {
  initialize() {
    const type = this.data.get('type');

    App.showNotification(this.element.textContent, type);
    this.element.remove();
  }
}
