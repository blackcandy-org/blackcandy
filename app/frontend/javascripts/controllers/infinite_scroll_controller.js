import { Controller } from 'stimulus';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = ['trigger']

  connect() {
    if (!this.hasNextPage) { return; }

    const watcher = this.createWatcher();
    this.bindNextPageEvent(watcher);
  }

  disconnect() {
    this.watcher.destroy();
  }

  createWatcher() {
    const scrollMonitor = require('scrollmonitor');
    const containerMonitor = scrollMonitor.createContainer(this.data.get('container'));
    this.watcher = containerMonitor.create(this.triggerTarget);

    return this.watcher;
  }

  bindNextPageEvent(watcher) {
    let ajaxRequest;

    watcher.enterViewport(() => {
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
