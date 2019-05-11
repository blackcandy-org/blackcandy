import { Controller } from 'stimulus';

export default class extends Controller {
  initialize() {
    this.show = this.show.bind(this);
    this.hide = this.hide.bind(this);
  }

  connect() {
    this.element.addEventListener('hide.dialog', this.hide);
    this.element.addEventListener('show.dialog', this.show);
  }

  disconnect() {
    this.element.removeEventListener('hide.dialog', this.hide);
    this.element.removeEventListener('show.dialog', this.show);
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
