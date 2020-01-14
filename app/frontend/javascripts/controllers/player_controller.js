import { Controller } from 'stimulus';
import { ajax } from '@rails/ujs';
import { Howl } from 'howler';
import { formatDuration, toggleShow } from '../helper';

export default class extends Controller {
  static targets = [
    'header',
    'headerContent',
    'image',
    'songName',
    'artistName',
    'albumName',
    'songDuration',
    'songTimer',
    'progress',
    'playButton',
    'pauseButton',
    'favoriteButton',
    'modeButton',
    'loader'
  ];

  initialize() {
    this._initPlayer();
    this._initPlaylist();
    this._initMode();
  }

  connect() {
    document.addEventListener('player:beforePlaying', this._setBeforePlayingStatus);
    document.addEventListener('player:playing', this._setPlayingStatus);
    document.addEventListener('player:pause', this._setPauseStatus);
    document.addEventListener('player:stop', this._setStopStatus);
    document.addEventListener('player:end', this._setEndStatus);
  }

  disconnect() {
    document.removeEventListener('player:beforePlaying', this._setBeforePlayingStatus);
    document.removeEventListener('player:playing', this._setPlayingStatus);
    document.removeEventListener('player:pause', this._setPauseStatus);
    document.removeEventListener('player:stop', this._setStopStatus);
    document.removeEventListener('player:end', this._setEndStatus);
  }

  play() {
    this.player.play(this.currentIndex);
  }

  pause() {
    this.player.pause();
  }

  toggleFavorite() {
    if (!this.currentSong.howl) { return; }

    const isFavorited = this.currentSong.is_favorited;

    ajax({
      url: '/favorite_playlist/songs',
      type: isFavorited ? 'delete' : 'post',
      data: `song_ids[]=${this.currentSong.id}`,
      success: () => {
        this.favoriteButtonTarget.classList.toggle('player__favorite');
        this.currentSong.is_favorited = !isFavorited;
      }
    });
  }

  nextMode() {
    if (this.currentModeIndex + 1 >= this.modes.length) {
      this.currentModeIndex = 0;
    } else {
      this.currentModeIndex += 1;
    }

    this.updateMode();
  }

  updateMode() {
    toggleShow(this.modeButtonTargets, this.modeButtonTargets[this.currentModeIndex]);
    this.player.playlist.isShuffled = (this.currentMode == 'shuffle');
  }

  next() {
    this.player.next();
  }

  previous() {
    this.player.previous();
  }

  seek(event) {
    this.player.seek(event.offsetX / event.target.offsetWidth);
    window.requestAnimationFrame(this._setProgress.bind(this));
  }

  collapse() {
    document.querySelector('#js-sidebar').classList.remove('show');
    document.body.classList.remove('noscroll');
  }

  get currentIndex() {
    return this.player.currentIndex;
  }

  get currentSong() {
    return this.player.currentSong;
  }

  get currentMode() {
    return this.modes[this.currentModeIndex];
  }

  _setBeforePlayingStatus = () => {
    this.headerTarget.classList.add('expand');
    this.loaderTarget.classList.remove('hidden');
  }

  _setPlayingStatus = () => {
    const { currentSong } = this;

    this.imageTarget.src = currentSong.album_image_url;
    this.songNameTarget.textContent = currentSong.name;
    this.artistNameTarget.textContent = currentSong.artist_name;
    this.albumNameTarget.textContent = currentSong.album_name;
    this.songDurationTarget.textContent = formatDuration(currentSong.length);

    this.headerContentTarget.classList.add('show');
    this.favoriteButtonTarget.classList.toggle('player__favorite', currentSong.is_favorited);
    this.pauseButtonTarget.classList.remove('hidden');
    this.playButtonTarget.classList.add('hidden');
    this.loaderTarget.classList.add('hidden');

    window.requestAnimationFrame(this._setProgress.bind(this));

    // let playlist can show current palying song
    App.dispatchEvent(document, 'playlistSongs:showPlaying');
  }

  _setPauseStatus = () => {
    this.pauseButtonTarget.classList.add('hidden');
    this.playButtonTarget.classList.remove('hidden');
  }

  _setStopStatus = () => {
    if (!this.player.playlist.length) {
      this.headerTarget.classList.remove('show');
    }
  }

  _setEndStatus = () => {
    if (this.currentMode == 'single') {
      this.player.play(this.currentIndex);
    } else {
      this.next();
    }
  }

  _setProgress() {
    let currentTime = this.currentSong.howl ? this.currentSong.howl.seek() : 0;
    currentTime = (typeof currentTime == 'number') ? Math.round(currentTime) : 0;

    this.songTimerTarget.textContent = formatDuration(currentTime);
    this.progressTarget.value = (currentTime / this.currentSong.length) * 100 || 0;

    if (this.player.isPlaying) {
      window.requestAnimationFrame(this._setProgress.bind(this));
    }
  }

  _initPlayer() {
    // Hack for Safari issue of can not play song when first time page loaded.
    // So call Howl init function manually let document have audio unlock event when click or touch.
    // When first time user interact page the audio will be unlocked.
    new Howl({ src: [''], format: ['mp3'] });

    this.player = App.player;
  }

  _initPlaylist() {
    ajax({
      url: '/current_playlist/songs?init=true',
      type: 'get',
      dataType: 'script'
    });
  }

  _initMode() {
    this.modes = ['repeat', 'single', 'shuffle'];
    this.currentModeIndex = 0;
    this.updateMode();
  }
}
