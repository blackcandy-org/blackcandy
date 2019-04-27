import { Controller } from 'stimulus';
import { ajax } from 'rails-ujs';
import { Howl } from 'howler';
import { formatDuration, toggleShow } from '../helper';

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
    this._initPlaylist();
    this._initMode();
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
        this.currentSong.is_favorited = true;
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

  seek(event) {
    this.player.seek(event.offsetX / event.target.offsetWidth);
    window.requestAnimationFrame(this._setProgress.bind(this));
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
    const { currentSong } = this;

    this.imageTarget.src = currentSong.album_image_url;
    this.songNameTarget.textContent = currentSong.name;
    this.artistNameTarget.textContent = currentSong.artist_name;
    this.albumNameTarget.textContent = currentSong.album_name;
    this.songDurationTarget.textContent = formatDuration(currentSong.length);

    this.favoriteButtonTarget.classList.toggle('player__favorite', currentSong.is_favorited);
    this.headerTarget.classList.add('player__header--show');
    this.pauseButtonTarget.classList.remove('hidden');
    this.playButtonTarget.classList.add('hidden');

    window.requestAnimationFrame(this._setProgress.bind(this));

    // let playlist can show current palying song
    App.dispatchEvent(document, 'show.playingitem');
  }

  _setPauseStatus() {
    this.pauseButtonTarget.classList.add('hidden');
    this.playButtonTarget.classList.remove('hidden');
  }

  _setStopStatus() {
    if (!this.player.playlist.length) {
      this.headerTarget.classList.remove('player__header--show');
    }
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
    // Hack for Safari issue of can not play song when first time page loaded.
    // So call Howl init function manually let document have audio unlock event when click or touch.
    // When first time user interact page the audio will be unlocked.
    new Howl({ src: [''], format: ['mp3'] });

    this.player = App.player;

    this.player.onplay = () => {
      this._setPlayingStatus();
    };

    this.player.onpause = () => {
      this._setPauseStatus();
    };

    this.player.onstop = () => {
      this._setStopStatus();
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
      url: '/playlist/current?init=true',
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
