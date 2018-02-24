import { Controller } from 'stimulus';
import notie from 'notie';

export default class extends Controller {
  connect() {
    this.element.style.display = 'none';

    const types = ['success', 'warning', 'error', 'info', 'neutral'];
    const type = this.data.get('type');

    notie.alert({
      type: types.includes(type) ? type : 'error',
      text: this.element.textContent
    });
  }
}
