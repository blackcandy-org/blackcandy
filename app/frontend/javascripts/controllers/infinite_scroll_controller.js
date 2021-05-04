import { Controller } from 'stimulus';
import { fetchTurboStream } from '../helper';

export default class extends Controller {
  static targets = ['trigger']

  static values = {
    container: String,
    url: String,
    totalPages: Number
  }

  initialize() {
    this.page = 2;
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

      if (this.abortController) {
        // Abort previous fetch request.
        this.abortController.abort();
      }

      this.abortController = new AbortController();

      const nextUrl = `${this.urlValue}?page=${this.page}`;

      fetchTurboStream(nextUrl, { signal: this.abortController.signal }, () => {
        this.page += 1;
      });
    });
  }

  get hasNextPage() {
    return this.page <= this.totalPagesValue;
  }
}
