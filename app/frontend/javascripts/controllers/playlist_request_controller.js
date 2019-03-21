import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('ajax:beforeSend', this.handleRequest.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('ajax:beforeSend', this.handleRequest.bind(this));
  }

  handleRequest({ target }) {
    if (target.dataset.showLoading) {
      App.dispatchEvent('#js-playlist-loading', 'show.loading');
    }
  }
}
