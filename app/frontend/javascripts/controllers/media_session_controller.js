import { Controller } from 'stimulus';

export default class extends Controller {
  DEFAULT_SKIP_TIME = 10;

  connect() {
    if (!('mediaSession' in navigator)) { return; }

    document.addEventListener('player:playing', this._setPlayingStatus);

    Object.entries(this.mediaSessionActions).forEach(([actionName, actionHandler]) => {
      try {
        navigator.mediaSession.setActionHandler(actionName, actionHandler);
      } catch (error) {
        // The media session ation is not supported.
      }
    });
  }

  disconnect() {
    if (!('mediaSession' in navigator)) { return; }

    document.removeEventListener('player:playing', this._setPlayingStatus);
  }


  _setPlayingStatus = () => {
    this._updateMetadata();
    this._updatePositionState();
  }

  _updateMetadata = () => {
    navigator.mediaSession.metadata = new MediaMetadata({
      title: this.currentSong.name,
      artist: this.currentSong.artist_name,
      album: this.currentSong.album_name,
      artwork: [
        { src: this.currentSong.album_image_url.small, sizes: '200x200' },
        { src: this.currentSong.album_image_url.medium, sizes: '300x300' },
        { src: this.currentSong.album_image_url.large, sizes: '400x400' },
      ]
    });
  }

  _updatePositionState = () => {
    if (!('setPositionState' in navigator.mediaSession)) { return; }

    navigator.mediaSession.setPositionState({
      duration: this.currentSong.length,
      playbackRate: this.currentSong.howl.rate(),
      position: this.currentSong.howl.seek()
    });
  }

  _play = () => {
    this.player.play(this.currentIndex);
  }

  _pause = () => {
    this.player.pause();
  }

  _next = () => {
    this.player.next();
  }

  _previous = () => {
    this.player.previous();
  }

  _stop = () => {
    this.player.stop();
  }

  _seekBackward = (event) => {
    const skipTime = event.seekOffset || this.DEFAULT_SKIP_TIME;

    this.player.seek(this.currentSong.howl.seek() - skipTime);
    this._updatePositionState();
  }

  _seekForward = (event) => {
    const skipTime = event.seekOffset || this.DEFAULT_SKIP_TIME;

    this.player.seek(this.currentSong.howl.seek() + skipTime);
    this._updatePositionState();
  }

  _seekTo = (event) => {
    this.player.seek(event.seekTime);
    this._updatePositionState();
  }

  get mediaSessionActions() {
    return {
      play: this._play,
      pause: this._pause,
      previoustrack: this._previous,
      nexttrack: this._next,
      stop: this._stop,
      seekbackward: this._seekBackward,
      seekforward: this._seekForward,
      seekto: this._seekTo
    };
  }

  get player() {
    return App.player;
  }

  get currentSong() {
    return this.player.currentSong;
  }

  get currentIndex() {
    return this.player.currentIndex;
  }
}
