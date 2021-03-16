import { Controller } from 'stimulus';
import { ajax } from '@rails/ujs';

export default class extends Controller {
  static targets = ['item'];

  static values = {
    playlistId: Number,
    isCurrent: Boolean,
    playlistSongs: Array
  }

  initialize() {
    this.player = App.player;

    if (this.isCurrentValue && this.hasPlaylistSongsValue) {
      this.player.stop();
      this.player.playlist.update(this.playlistSongsValue);
    }
  }

  connect() {
    this._showPlayingItem();
    document.addEventListener('playlistSongs:showPlaying', this._showPlayingItem);
  }

  disconnect() {
    document.removeEventListener('playlistSongs:showPlaying', this._showPlayingItem);
  }

  actionHandler({ target }) {
    const actionElement = target.closest('[data-playlist-songs-action]');

    if (!actionElement) { return; }

    switch (actionElement.dataset.playlistSongsAction) {
      case 'delete':
        this._delete(target);
        break;
      case 'play':
        this._play(target);
        break;
      case 'none':
        break;
    }
  }

  _showPlayingItem = () => {
    this.itemTargets.forEach((element) => {
      element.classList.toggle('is-active', element.dataset.songId == this.player.currentSong.id);
    });
  }

  _play(target) {
    const { songId } = target.closest('[data-song-id]').dataset;
    const playlistIndex = this.player.playlist.indexOf(songId);

    if (playlistIndex != -1) {
      this.player.skipTo(playlistIndex);
    } else {
      ajax({
        url: '/current_playlist/songs',
        type: 'post',
        data: `song_ids[]=${songId}`,
        success: () => {
          this.player.skipTo(this.player.playlist.pushSong(songId));
        }
      });
    }
  }

  _delete(target) {
    const { songId } = target.closest('[data-song-id]').dataset;

    if (this.isCurrentValue) {
      const songIndex = this.player.playlist.deleteSong(songId);
      if (this.player.currentSong.id == songId) { this.player.skipTo(songIndex); }
    }
  }
}
