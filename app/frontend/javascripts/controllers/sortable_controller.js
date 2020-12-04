import { Controller } from 'stimulus';
import { Sortable, Plugins } from '@shopify/draggable';

export default class extends Controller {
  connect() {
    this.sortable = new Sortable(this.element, {
      draggable: '.js-sortable-item',
      handle: '.js-sortable-item-handle',
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
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy();
    }
  }
}
