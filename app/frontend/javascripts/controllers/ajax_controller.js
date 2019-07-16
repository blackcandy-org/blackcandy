import { Controller } from 'stimulus';

export default class extends Controller {
  initialize() {
    this._beforeSend = this._beforeSend.bind(this);
  }

  connect() {
    this.element.addEventListener('ajax:beforeSend', this._beforeSend);
  }

  disconnect() {
    this.element.removeEventListener('ajax:beforeSend', this._beforeSend);
  }

  _beforeSend({ target }) {
    if (target.dataset.showLoader) {
      App.dispatchEvent(this.data.get('loader'), 'loader:show');
      target.addEventListener('ajax:success', this._success.bind(this), { once: true });
    }
  }

  _success({ target }) {
    if (target.dataset.showLoader) {
      App.dispatchEvent(this.data.get('loader'), 'loader:hide');
    }
  }
}
