import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['input', 'clear'];

  connect() {
    this.updateInput();
  }

  updateInput() {
    if (this.hasContent) {
      this.clearTarget.classList.remove('hidden');
    } else {
      this.clearTarget.classList.add('hidden');
    }
  }

  get hasContent() {
    return !!this.inputTarget.value;
  }
}
