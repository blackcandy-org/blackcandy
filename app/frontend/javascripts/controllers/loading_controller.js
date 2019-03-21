import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['content', 'indicator'];

  connect() {
    this.element.addEventListener('hide.loading', this.hide.bind(this));
    this.element.addEventListener('show.loading', this.show.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('hide.loading', this.hide.bind(this));
    this.element.removeEventListener('show.loading', this.show.bind(this));
  }

  show() {
    this.contentTarget.classList.add('hidden');
    this.indicatorTarget.classList.remove('hidden');
  }

  hide() {
    this.contentTarget.classList.remove('hidden');
    this.indicatorTarget.classList.add('hidden');
  }
}
