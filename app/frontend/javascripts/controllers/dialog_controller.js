import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    this.element.addEventListener('hide.dialog', this.hide.bind(this));
    this.element.addEventListener('show.dialog', this.show.bind(this));
  }

  disconnect() {
    this.element.removeEventListener('hide.dialog', this.hide.bind(this));
    this.element.removeEventListener('show.dialog', this.show.bind(this));
  }

  show() {
    if (!document.querySelector('.overlay')) {
      const overlayElement = document.createElement('div');

      overlayElement.classList.add('overlay');
      document.body.appendChild(overlayElement);
    } else {
      document.querySelector('.overlay').classList.remove('hidden');
    }

    this.element.classList.remove('hidden');
  }

  hide() {
    document.querySelector('.overlay').classList.add('hidden');
    this.element.classList.add('hidden');
  }
}
