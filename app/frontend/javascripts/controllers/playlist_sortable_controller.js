import { Controller } from 'stimulus';
import { Sortable, Plugins } from '@shopify/draggable';
import { ajax } from '@rails/ujs';

export default class extends Controller {
  static values = {
    playlistId: Number
  }

  connect() {
    this.sortable = new Sortable(this.element, {
      draggable: '.js-playlist-sortable-item',
      handle: '.js-playlist-sortable-item-handle',
      swapAnimation: {
        duration: 150,
        easingFunction: 'ease-in-out',
      },

      mirror: {
        appendTo: this.element,
        constrainDimensions: true,
      },

      classes: {
        'source:dragging': 'is-dragging-placeholder',
        mirror: 'is-dragging'
      },

      plugins: [Plugins.SwapAnimation]
    });

    this.sortable.on('sortable:stop', this._reorderPlaylist);
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy();
    }
  }

  _reorderPlaylist = (event) => {
    App.player.playlist.move(event.oldIndex, event.newIndex);

    ajax({
      url: `/playlists/${this.playlistIdValue}/songs`,
      type: 'put',
      data: `from_position=${event.oldIndex + 1}&to_position=${event.newIndex + 1}`
    });
  }
}
