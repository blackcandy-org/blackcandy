import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['item'];

  connect() {
    this._toggleWithIndex(0);
  }

  toggle({ target }) {
    if (this.itemTargets.includes(target)) {
      this._toggleWithIndex(this.itemTargets.indexOf(target));
    }
  }

  _toggleWithIndex(index) {
    this.itemTargets.forEach((element, elementIndex) => {
      element.closest('.tab__item').classList.toggle('tab__item--active', index == elementIndex);
    });
  }
}
