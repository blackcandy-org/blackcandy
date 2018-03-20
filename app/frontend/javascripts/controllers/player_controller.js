import { Controller } from 'stimulus';
import Player from '../player';

const defaultVolume = 0.5;

export default class extends Controller {
  static targets = ['mainButton', 'volumeInput'];

  connect() {
    this.player = new Player(this.playlistController.playlistContent);

    this.player.onplay = () => {
      this.mainButtonTarget.classList.add('player__control__main--playing');
      this.playlistController.showCurrentItem(this.currentIndex);
    };

    this.player.onpause = () => {
      this.mainButtonTarget.classList.remove('player__control__main--playing');
    };

    this.volumeInputTarget.value = localStorage.getItem('volume') || defaultVolume;
    // dispatch change event on player volume input.
    this.volumeInputTarget.dispatchEvent(new Event('change'));
  }

  togglePlay() {
    if (this.player.isPlaying()) {
      this.player.pause();
    } else {
      this.player.play(this.currentIndex);
    }
  }

  next() {
    this.player.next();
  }

  previous() {
    this.player.previous();
  }

  changeVolume(event) {
    this.player.volume(event.target.value);
  }

  get playlistController() {
    const playlist = document.querySelector('#js-playlist');
    return this.application.getControllerForElementAndIdentifier(playlist, 'playlist');
  }

  get currentIndex() {
    return this.player.currentIndex;
  }
}
