import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('ajax:beforeSend', this._beforeSend.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('ajax:beforeSend', this._beforeSend.bind(this));
  }

  _beforeSend({ target }) {
    if (target.dataset.showLoader) {
      App.dispatchEvent(this.data.get('loader'), 'show.loader');
      target.addEventListener('ajax:success', this._success.bind(this), { once: true });
    }
  }

  _success({ target }) {
    if (target.dataset.showLoader) {
      App.dispatchEvent(this.data.get('loader'), 'hide.loader');
    }
  }
}
