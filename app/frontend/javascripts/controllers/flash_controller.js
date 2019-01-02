import { Controller } from 'stimulus';
import Noty from 'noty';

export default class extends Controller {
  connect() {
    this.element.classList.add('hidden');

    const types = ['success', 'error'];
    const type = this.data.get('type');

    new Noty({
      type: types.includes(type) ? type : 'success',
      text: this.element.textContent,
      layout: 'topCenter',
      timeout: 2500,
      progressBar: false
    }).show();
  }
}
