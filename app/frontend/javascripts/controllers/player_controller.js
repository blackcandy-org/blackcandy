import { Controller } from 'stimulus';
import { formatDuration, toggleHide, toggleShow } from '../helper';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = [
    'header',
    'image',
    'songName',
    'artistName',
    'albumName',
    'songDuration',
    'songTimer',
    'progress',
    'playButton',
    'favoriteButton',
    'modeButton'
  ];

  initialize() {
    this._initPlayer();
    this._initMode();
    this._initPlaylist();
  }

  togglePlay(event) {
    toggleHide(this.playButtonTargets, event.currentTarget);

    if (this.player.isPlaying()) {
      this.player.pause();
    } else {
      this.player.play(this.currentIndex);
    }
  }

  toggleFavorite() {
    if (!this.currentSong.howl) { return; }

    ajax({
      url: `/songs/${this.currentSong.id}/favorite`,
      type: 'post',
      success: () => {
        this.favoriteButtonTarget.classList.toggle('player__favorite');
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

    this.player.isShuffle = this.currentMode == 'shuffle';
  }

  next() {
    this.player.next();
  }

  previous() {
    this.player.previous();
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

  _setPlayingStatus() {
    this.imageTarget.src = this.currentSong.album_image_url;
    this.songNameTarget.textContent = this.currentSong.name;
    this.artistNameTarget.textContent = this.currentSong.artist_name;
    this.albumNameTarget.textContent = this.currentSong.album_name;
    this.songDurationTarget.textContent = formatDuration(this.currentSong.length);
    this.favoriteButtonTarget.classList.toggle('player__favorite', this.currentSong.is_favorited);
    this.headerTarget.classList.add('player__header--show');

    window.requestAnimationFrame(this._setProgress.bind(this));
  }

  _setProgress() {
    const seek = this.currentSong.howl ? this.currentSong.howl.seek() : 0;

    this.songTimerTarget.textContent = formatDuration(Math.round(seek));
    this.progressTarget.value = (seek / this.currentSong.length) * 100 || 0;

    if (this.player.isPlaying()) {
      window.requestAnimationFrame(this._setProgress.bind(this));
    }
  }

  _initPlayer() {
    this.player = App.player;

    this.player.onplay = () => {
      this._setPlayingStatus();
    };

    this.player.onend = () => {
      if (this.currentMode == 'single') {
        this.player.play(this.currentIndex);
      } else {
        this.next();
      }
    };
  }

  _initPlaylist() {
    ajax({
      url: '/playlist/current',
      type: 'get',
      dataType: 'json',
      success: (response) => {
        this.player.updatePlaylist(response);
      }
    });
  }

  _initMode() {
    this.modes = ['normal', 'shuffle', 'single'];
    this.currentModeIndex = 0;
    this.updateMode();
  }
}
