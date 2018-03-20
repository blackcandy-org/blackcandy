import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['item'];

  play(event) {
    const playlistIndex = parseInt(event.currentTarget.dataset.playlistIndex, 10);

    this.playerController.player.play(playlistIndex);
    this.showCurrentItem(playlistIndex);
  }

  showCurrentItem(playlistIndex) {
    this.itemTargets.forEach((element, index) => {
      element.classList.toggle('playlist__item--current', playlistIndex == index);
    });
  }

  get playlistContent() {
    return JSON.parse(this.data.get('content'));
  }

  get playerController() {
    const player = document.querySelector('#js-player');
    return this.application.getControllerForElementAndIdentifier(player, 'player');
  }
}
