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
    document.querySelector('#js-sidebar').classList.add('show');
    document.body.classList.add('noscroll');
  }

  _setBeforePlayingStatus = () => {
    this.loaderTarget.classList.remove('hidden');
    this.songNameTarget.classList.add('hidden');
  }

  _setPlayingStatus = () => {
    this.songNameTarget.textContent = this.player.currentSong.name;
    this.loaderTarget.classList.add('hidden');
    this.songNameTarget.classList.remove('hidden');
    this.pauseButtonTarget.classList.remove('hidden');
    this.playButtonTarget.classList.add('hidden');
  }

  _setPauseStatus = () => {
    this.pauseButtonTarget.classList.add('hidden');
    this.playButtonTarget.classList.remove('hidden');
  }

  _initPlayer() {
    this.player = App.player;
  }
}
