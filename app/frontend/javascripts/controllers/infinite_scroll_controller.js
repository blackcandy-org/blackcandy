import { Controller } from 'stimulus';
import { ajax } from '@rails/ujs';

export default class extends Controller {
  static targets = ['trigger']

  static values = {
    container: String,
    nextUrl: String
  }

  connect() {
    if (!this.hasNextPage) { return; }

    this.observer = new IntersectionObserver(this._handleNextPageLoad.bind(this), {
      root: this.hasContainerValue ? document.querySelector(this.containerValue) : document,
      rootMargin: '0px',
      threshold: 1.0
    });

    this.observer.observe(this.triggerTarget);
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }

  _handleNextPageLoad(entries) {
    entries.forEach((entry) => {
      if (!entry.intersectionRatio == 1) { return; }

      if (!this.hasNextPage) {
        this.triggerTarget.classList.add('u-display-none');
        return;
      }

      if (this.ajaxRequest) {
        // Abort previous ajax request.
        this.ajaxRequest.abort();
      }

      ajax({
        url: this.nextUrlValue,
        type: 'get',
        dataType: 'script',
        beforeSend: (xhr) => {
          this.ajaxRequest = xhr;
          return true;
        }
      });
    });
  }

  get hasNextPage() {
    return !!this.nextUrlValue;
  }
}
