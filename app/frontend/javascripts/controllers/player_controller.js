import { Controller } from 'stimulus';
import { formatDuration, toggleShow, dispatchEvent } from '../helper';
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
    'pauseButton',
    'favoriteButton',
    'modeButton'
  ];

  initialize() {
    this._initPlayer();
    this._initMode();
    this._initPlaylist();
  }

  play() {
    this.player.play(this.currentIndex);
  }

  pause() {
    this.player.pause();
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

    this.player.updateShuffleStatus(this.currentMode == 'shuffle');
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
    this.pauseButtonTarget.classList.remove('hidden');
    this.playButtonTarget.classList.add('hidden');

    window.requestAnimationFrame(this._setProgress.bind(this));

    // let playlist can show current palying song
    dispatchEvent(document, 'showPlayingItem');
  }

  _setPauseStatus() {
    this.pauseButtonTarget.classList.add('hidden');
    this.playButtonTarget.classList.remove('hidden');
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

    this.player.onpause = () => {
      this._setPauseStatus();
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
    this.modes = ['normal', 'single', 'shuffle'];
    this.currentModeIndex = 0;
    this.updateMode();
  }
}
