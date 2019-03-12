import { Controller } from 'stimulus';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = ['item', 'content', 'spinner'];

  initialize() {
    const firstTabUrl = this.itemTargets[0].getAttribute('href');
    this._toggleWithIndex(0);

    ajax({
      url: firstTabUrl,
      type: 'get',
      dataType: 'script'
    });
  }

  toggle({ target }) {
    if (this.itemTargets.includes(target)) {
      this._toggleWithIndex(this.itemTargets.indexOf(target));
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
