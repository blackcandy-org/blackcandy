import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['item', 'content', 'spinner'];

  initialize() {
    this._toggleWithIndex(0);
  }

  connect() {
    this.element.addEventListener('ajax:beforeSend', this.handleRequest.bind(this));
    this.element.addEventListener('hide.spinner', this.hideSpinner.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('ajax:beforeSend', this.handleRequest.bind(this));
    this.element.removeEventListener('hide.spinner', this.hideSpinner.bind(this));
  }

  toggle({ target }) {
    if (this.itemTargets.includes(target)) {
      this._toggleWithIndex(this.itemTargets.indexOf(target));
    }
  }

  handleRequest({ target }) {
    if (target.dataset.showSpinner) {
      this.showSpinner();
    }
  }

  showSpinner() {
    this.spinnerTarget.classList.remove('hidden');
    this.contentTarget.classList.add('hidden');
  }

  hideSpinner() {
    this.spinnerTarget.classList.add('hidden');
    this.contentTarget.classList.remove('hidden');
  }

  _toggleWithIndex(index) {
    this.itemTargets.forEach((element, elementIndex) => {
      element.closest('.tab__item').classList.toggle('tab__item--active', index == elementIndex);
    });
  }
}
