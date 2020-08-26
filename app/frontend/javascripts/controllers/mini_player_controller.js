import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['songName', 'playButton', 'pauseButton', 'loader'];

  initialize() {
    this._initPlayer();
  }

  connect() {
    document.addEventListener('player:beforePlaying', this._setBeforePlayingStatus);
    document.addEventListener('player:playing', this._setPlayingStatus);
    document.addEventListener('player:pause', this._setPauseStatus);
  }

  disconnect() {
    document.removeEventListener('player:beforePlaying', this._setBeforePlayingStatus);
    document.removeEventListener('player:playing', this._setPlayingStatus);
    document.removeEventListener('player:pause', this._setPauseStatus);
  }

  play() {
    this.player.play(this.player.currentIndex);
  }

  pause() {
    this.player.pause();
  }

  next() {
    this.player.next();
  }

  expand() {
    document.querySelector('#js-sidebar').classList.add('is-expanded');
  }

  _setBeforePlayingStatus = () => {
    this.loaderTarget.classList.remove('u-display-none');
    this.songNameTarget.classList.add('u-display-none');
  }

  _setPlayingStatus = () => {
    this.songNameTarget.textContent = this.player.currentSong.name;
    this.loaderTarget.classList.add('u-display-none');
    this.songNameTarget.classList.remove('u-display-none');
    this.pauseButtonTarget.classList.remove('u-display-none');
    this.playButtonTarget.classList.add('u-display-none');
  }

  _setPauseStatus = () => {
    this.pauseButtonTarget.classList.add('u-display-none');
    this.playButtonTarget.classList.remove('u-display-none');
  }

  _initPlayer() {
    this.player = App.player;
  }
}
