import { Controller } from 'stimulus';
import feather from 'feather-icons';

export default class extends Controller {
  connect() {
    const iconType = this.data.get('type');
    this.element.outerHTML = feather.icons[iconType].toSvg({ width: 20, height: 20 });
  }
}
