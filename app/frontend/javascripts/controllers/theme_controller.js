import { Controller } from 'stimulus';

export default class extends Controller {
  update(event) {
    if (!event.detail.success) { return; }

    document.documentElement.setAttribute('data-color-scheme', this.theme);
  }

  select(event) {
    this.theme = event.target.dataset.theme;
  }
}
