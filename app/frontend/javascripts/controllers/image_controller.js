import { Controller } from 'stimulus';

export default class extends Controller {
  loadDefault(event) {
    const type = this.data.get('type');
    event.target.src = `/images/default_${type}.png`;
  }
}
