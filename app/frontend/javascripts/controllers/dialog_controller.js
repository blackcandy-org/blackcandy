import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('dialog:hide', this.hide);
    this.element.addEventListener('dialog:show', this.show);
  }

  disconnect() {
    this.element.removeEventListener('dialog:hide', this.hide);
    this.element.removeEventListener('dialog:show', this.show);
  }

  show = () => {
    document.querySelector('#js-overlay').classList.remove('hidden');
    this.element.classList.remove('hidden');
  }

  hide = () => {
    document.querySelector('#js-overlay').classList.add('hidden');
    this.element.classList.add('hidden');
  }
}
