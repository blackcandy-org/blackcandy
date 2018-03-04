import { Controller } from 'stimulus';
import Player from '../player';

export default class extends Controller {
  static targets = ['item'];

  connect() {
    this.player = new Player(JSON.parse(this.data.get('content')));
  }

  play(event) {
    const playlistIndex = parseInt(event.currentTarget.dataset.playlistIndex, 10);

    this.player.play(playlistIndex);
    this.showCurrentItem(playlistIndex);
  }

  showCurrentItem(playlistIndex) {
    this.itemTargets.forEach((element, index) => {
      element.classList.toggle('playlist__item--current', playlistIndex == index);
    });
  }
}
