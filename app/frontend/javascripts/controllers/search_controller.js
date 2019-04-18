import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['loader'];

  AVAILABLE_RESOURCES = ['albums', 'artists', 'songs'];
  SEARCH_TIMEOUT = 800

  query({ target }) {
    this.loaderTarget.classList.remove('hidden');

    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }

    this.searchTimeout = setTimeout(() => {
      const queryUrl = this.AVAILABLE_RESOURCES.includes(this.resource) ? `/${this.resource}` : '/albums';

      Turbolinks.visit(`${queryUrl}?query=${target.value.trim()}`);
      this._focusInput();
    }, this.SEARCH_TIMEOUT);
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
