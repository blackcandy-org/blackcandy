import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['item'];

  static values = {
    playlistId: Number,
    isCurrent: Boolean,
    isPlayable: Boolean,
    playlistSongs: Array
  }

  initialize() {
    if (!this.isCurrentValue) { return; }

    if (this.hasPlaylistSongsValue) {
      this.player.playlist.update(this.playlistSongsValue);
    }

    if (this.isPlayableValue) {
      this.player.skipTo(0);
    }
  }

  connect() {
    this._showPlayingItem();
    document.addEventListener('playlistSongs:showPlaying', this._showPlayingItem);
  }

  disconnect() {
    document.removeEventListener('playlistSongs:showPlaying', this._showPlayingItem);
  }

  submitStartHandle(event) {
    const actionElement = event.target.closest('[data-submit-start-action]');

    if (!actionElement) { return; }

    switch (actionElement.dataset.submitStartAction) {
      case 'check_before_playing':
        this._checkBeforePlaying(event);
        break;
    }
  }

  submitEndHandle(event) {
    const actionElement = event.target.closest('[data-submit-end-action]');

    if (!actionElement || !event.detail.success) { return; }

    switch (actionElement.dataset.submitEndAction) {
      case 'delete':
        this._delete(event.target);
        break;
      case 'play':
        this._play(event.target);
        break;
    }
  }

  _showPlayingItem = () => {
    this.itemTargets.forEach((element) => {
      element.classList.toggle('is-active', element.dataset.songId == this.player.currentSong.id);
    });
  }

  _checkBeforePlaying(event) {
    const { songId } = event.target.closest('[data-song-id]').dataset;
    const playlistIndex = this.player.playlist.indexOf(songId);

    if (playlistIndex != -1) {
      event.detail.formSubmission.stop();
      this.player.skipTo(playlistIndex);
    }
  }

  _play(target) {
    const { songId } = target.closest('[data-song-id]').dataset;

    this.player.skipTo(this.player.playlist.pushSong(songId));
  }

  _delete(target) {
    const { songId } = target.closest('[data-song-id]').dataset;

    if (!this.isCurrentValue) { return; }

    if (this.player.currentSong.id == songId) {
      this.player.skipTo(this.player.playlist.deleteSong(songId));
    }
  }

  get player() {
    return App.player;
  }
}
