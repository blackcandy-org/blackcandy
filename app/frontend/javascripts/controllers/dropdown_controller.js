import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['trigger', 'list'];

  showDropdown() {
    const closeDropdown = (event) => {
      if (event.target.parentNode !== this.triggerTarget) {
        this.listTarget.classList.add('hidden');
        document.removeEventListener('click', closeDropdown);
      }
    };

    this.listTarget.classList.remove('hidden');
    document.addEventListener('click', closeDropdown);
  }
}
