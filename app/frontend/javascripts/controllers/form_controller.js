import { Controller } from 'stimulus';
import { dispatchEvent } from '../helper';

export default class extends Controller {
  static values = {
    loader: String
  }

  connect() {
    if (!this.hasLoaderValue) { return; }

    this.element.addEventListener('turbo:submit-start', this._submitStart);
  }

  disconnect() {
    if (!this.hasLoaderValue) { return; }

    this.element.removeEventListener('turbo:submit-start', this._submitStart);
  }

  reset() {
    this.element.reset();
  }

  _submitStart = ({ target }) => {
    dispatchEvent(this.loaderValue, 'loader:show');
    target.addEventListener('turbo:submit-end', this._submitEnd.bind(this), { once: true });
  }

  _submitEnd() {
    dispatchEvent(this.loaderValue, 'loader:hide');
  }
}
