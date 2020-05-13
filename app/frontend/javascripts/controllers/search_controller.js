import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['loader', 'input'];

  AVAILABLE_RESOURCES = ['albums', 'artists', 'songs'];

  connect() {
    this.inputTarget.value = this.inputTarget.getAttribute('value');
  }

  disconnect() {
    this.loaderTarget.classList.add('hidden');
    this.inputTarget.value = '';
  }

  query(event) {
    if (event.key != 'Enter') { return; }

    this.loaderTarget.classList.remove('hidden');

    const baseUrl = this.AVAILABLE_RESOURCES.includes(this.resource) ? `/${this.resource}` : '/albums';
    const query = event.target.value.trim();
    const queryUrl = `${baseUrl}${query ? `?query=${query}` : ''}`;

    Turbolinks.visit(queryUrl);
    this._focusInput();
  }

  _focusInput() {
    document.addEventListener('turbolinks:load', () => {
      const searchElement = document.querySelector('#js-search-input');
      const searchValueLength = searchElement.value.length;

      searchElement.focus();
      searchElement.setSelectionRange(searchValueLength, searchValueLength);
    }, { once: true });
  }

  get resource() {
    return this.data.get('resource');
  }
}
