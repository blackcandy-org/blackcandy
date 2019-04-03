import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('hide.loader', this._hide.bind(this));
    this.element.addEventListener('show.loader', this._show.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('hide.loader', this._hide.bind(this));
    this.element.removeEventListener('show.loader', this._show.bind(this));
  }

  _show() {
    this.element.classList.remove('hidden');
  }

  _hide() {
    this.element.classList.add('hidden');
  }
}
