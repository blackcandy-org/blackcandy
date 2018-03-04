import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['trigger', 'list'];

  showDropdown() {
    const closeDropdown = (event) => {
      if (event.target.parentNode !== this.triggerTarget) {
        this.listTarget.classList.remove('dropdown--show');
        document.removeEventListener('click', closeDropdown);
      }
    };

    this.listTarget.classList.add('dropdown--show');
    document.addEventListener('click', closeDropdown);
  }
}
