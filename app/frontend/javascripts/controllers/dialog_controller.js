import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('hide.dialog', this.hide.bind(this));
    this.element.addEventListener('show.dialog', this.show.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('hide.dialog', this.hide.bind(this));
    this.element.removeEventListener('show.dialog', this.show.bind(this));
  }

  show() {
    document.querySelector('#js-overlay').classList.remove('hidden');
    this.element.classList.remove('hidden');
  }

  hide() {
    document.querySelector('#js-overlay').classList.add('hidden');
    this.element.classList.add('hidden');
  }
}
