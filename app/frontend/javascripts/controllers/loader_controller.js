import { Controller } from 'stimulus';

export default class extends Controller {
  initialize() {
    this._show = this._show.bind(this);
    this._hide = this._hide.bind(this);
  }

  connect() {
    this.element.addEventListener('hide.loader', this._hide);
    this.element.addEventListener('show.loader', this._show);
  }

  disconnect() {
    this.element.removeEventListener('hide.loader', this._hide);
    this.element.removeEventListener('show.loader', this._show);
  }

  _show() {
    this.element.classList.remove('hidden');
  }

  _hide() {
    this.element.classList.add('hidden');
  }
}
