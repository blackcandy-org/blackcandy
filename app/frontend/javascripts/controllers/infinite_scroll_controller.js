import { Controller } from 'stimulus';
import { ajax } from 'rails-ujs';
import ScrollMagic from 'scrollmagic';

export default class extends Controller {
  static targets = ['trigger']

  connect() {
    if (!this.hasNextPage) { return; }

    const scene = this.createScene();
    this.bindNextPageEvent(scene);
  }

  disconnect() {
    this.scrollController.destroy();
  }

  createScene() {
    this.scrollController = new ScrollMagic.Controller({
      container: this.data.get('container')
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

      ajax({
        url: this.data.get('nextUrl'),
        type: 'get',
        dataType: 'script',
        beforeSend(xhr) {
          ajaxRequest = xhr;
        }
      });
    });
  }

  get hasNextPage() {
    return this.triggerTarget.childElementCount != 0;
  }
}
