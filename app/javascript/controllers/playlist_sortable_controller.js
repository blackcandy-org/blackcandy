import { Controller } from '@hotwired/stimulus'
import { Sortable, Plugins } from '@shopify/draggable'
import { fetchRequest } from '../helper'

export default class extends Controller {
  static values = {
    url: String
  }

  connect () {
    this.sortable = new Sortable(this.element, {
      draggable: '.js-playlist-sortable-item',
      handle: '.js-playlist-sortable-item-handle',
      swapAnimation: {
        duration: 150,
        easingFunction: 'ease-in-out'
      },

      mirror: {
        appendTo: this.element,
        constrainDimensions: true
      },

      classes: {
        'source:dragging': 'is-dragging-placeholder',
        mirror: 'is-dragging'
      },

      plugins: [Plugins.SwapAnimation]
    })

    this.sortable.on('sortable:stop', this._reorderPlaylist)
  }

  disconnect () {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  _reorderPlaylist = (event) => {
    App.player.playlist.move(event.oldIndex, event.newIndex)

    fetchRequest(this.urlValue, {
      method: 'put',
      body: JSON.stringify({
        from_position: event.oldIndex + 1,
        to_position: event.newIndex + 1
      })
    })
  }
}
