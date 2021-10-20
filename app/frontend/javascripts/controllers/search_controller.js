import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['loader', 'input'];

  connect() {
    this.inputTarget.value = this.inputTarget.getAttribute('value');
  }

  disconnect() {
    this.loaderTarget.classList.add('u-display-none');
    this.inputTarget.value = '';
  }

  query(event) {
    const query = event.target.value.trim();

    if (event.key != 'Enter' || query == '') { return; }

    this.loaderTarget.classList.remove('u-display-none');
    const queryUrl = `/search${query ? `?query=${query}` : ''}`;

    Turbo.visit(queryUrl);
    this._focusInput();
  }

  _focusInput() {
    document.addEventListener('turbo:load', () => {
      const searchElement = document.querySelector('#js-search-input');
      const searchValueLength = searchElement.value.length;

      searchElement.focus();
      searchElement.setSelectionRange(searchValueLength, searchValueLength);
    }, { once: true });
  }
}
