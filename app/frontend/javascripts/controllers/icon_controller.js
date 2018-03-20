import { Controller } from 'stimulus';
import feather from 'feather-icons';

export default class extends Controller {
  connect() {
    const iconType = this.data.get('type');
    const elementClass = this.element.className;

    this.element.outerHTML = feather.icons[iconType].toSvg({
      class: elementClass
    });
  }
}
