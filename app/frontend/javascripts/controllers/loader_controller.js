import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['content', 'indicator'];

  connect() {
    this.element.addEventListener('loader:hide', this._hide);
    this.element.addEventListener('loader:show', this._show);
  }

  disconnect() {
    this.element.removeEventListener('loader:hide', this._hide);
    this.element.removeEventListener('loader:show', this._show);
  }

  _show = () => {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add('hidden');
    }

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.remove('hidden');
    }
  }

  _hide = () => {
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove('hidden');
    }

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.add('hidden');
    }
  }
}
