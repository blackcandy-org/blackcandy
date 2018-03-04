import { Controller } from 'stimulus';
import feather from 'feather-icons';

export default class extends Controller {
  connect() {
    const iconType = this.data.get('type');

    this.element.outerHTML = feather.icons[iconType].toSvg({
      class: 'icon',
      width: 15,
      height: 15
    });
  }
}
