import { Controller } from 'stimulus';
import feather from 'feather-icons';

export default class extends Controller {
  connect() {
    const type = this.data.get('type');
    const elementClass = this.element.className;

    this.element.outerHTML = feather.icons[type].toSvg({
      class: elementClass
    });
  }
}
