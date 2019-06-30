import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['songName', 'playButton', 'pauseButton', 'loader'];

  initialize() {
    this._initPlayer();
    this._setBeforePlayingStatus = this._setBeforePlayingStatus.bind(this);
    this._setPlayingStatus = this._setPlayingStatus.bind(this);
    this._setPauseStatus = this._setPauseStatus.bind(this);
  }

  connect() {
    document.addEventListener('set.beforePlayingStatus', this._setBeforePlayingStatus);
    document.addEventListener('set.playingStatus', this._setPlayingStatus);
    document.addEventListener('set.pauseStatus', this._setPauseStatus);
  }

  disconnect() {
    document.removeEventListener('set.beforePlayingStatus', this._setBeforePlayingStatus);
    document.removeEventListener('set.playingStatus', this._setPlayingStatus);
    document.removeEventListener('set.pauseStatus', this._setPauseStatus);
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

  _setBeforePlayingStatus() {
    this.loaderTarget.classList.remove('hidden');
    this.songNameTarget.classList.add('hidden');
  }

  _setPlayingStatus() {
    this.songNameTarget.textContent = this.player.currentSong.name;
    this.loaderTarget.classList.add('hidden');
    this.songNameTarget.classList.remove('hidden');
    this.pauseButtonTarget.classList.remove('hidden');
    this.playButtonTarget.classList.add('hidden');
  }

  _setPauseStatus() {
    this.pauseButtonTarget.classList.add('hidden');
    this.playButtonTarget.classList.remove('hidden');
  }

  _initPlayer() {
    this.player = App.player;
  }
}
