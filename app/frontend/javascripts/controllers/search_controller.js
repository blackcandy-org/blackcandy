import { Controller } from 'stimulus';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = ['loader'];

  AVAILABLE_RESOURCES = ['albums', 'artists', 'songs'];
  SEARCH_TIMEOUT = 600

  query({ target }) {
    this.loaderTarget.classList.remove('hidden');

    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }

    this.searchTimeout = setTimeout(() => {
      const queryUrl = this.AVAILABLE_RESOURCES.includes(this.resource) ? `/${this.resource}` : '/albums';

      ajax({
        url: `${queryUrl}?query=${target.value.trim()}`,
        type: 'get',
        dataType: 'script',
        success: () => {
          this.loaderTarget.classList.add('hidden');
        }
      });
    }, this.SEARCH_TIMEOUT);
  }

  get resource() {
    return this.data.get('resource');
  }
}
