import { Controller } from 'stimulus';
import { ajax } from '@rails/ujs';
import ScrollMagic from 'scrollmagic';

export default class extends Controller {
  static targets = ['trigger']

  connect() {
    if (!this.hasNextPage) { return; }

    const scene = this.createScene();
    this.bindNextPageEvent(scene);
  }

  disconnect() {
    if (this.scrollController) {
      this.scrollController.destroy(true);
    }
  }

  createScene() {
    this.scrollController = new ScrollMagic.Controller({
      container: this.data.get('container') || window
    });

    return new ScrollMagic.Scene({
      triggerElement: this.triggerTarget,
      triggerHook: 'onEnter'
    }).addTo(this.scrollController);
  }

  bindNextPageEvent(scene) {
    let ajaxRequest;

    scene.on('enter', () => {
      if (ajaxRequest) {
        // Abort previous ajax request.
        ajaxRequest.abort();
      }

      if (!this.hasNextPage) {
        this.triggerTarget.classList.add('hidden');
      }

      if (this.isTriggerHidden && !this.hasNextPage) { return; }

      ajax({
        url: this.nextUrl,
        type: 'get',
        dataType: 'script',
        beforeSend(xhr) {
          ajaxRequest = xhr;
          return true;
        }
      });
    });
  }

  get hasNextPage() {
    return !!this.nextUrl;
  }

  get nextUrl() {
    return this.data.get('nextUrl');
  }

  get isTriggerHidden() {
    return this.triggerTarget.offsetParent == null;
  }
}
