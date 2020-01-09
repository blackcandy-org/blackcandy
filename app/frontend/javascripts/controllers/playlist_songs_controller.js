import { Controller } from 'stimulus';
import { ajax } from '@rails/ujs';

export default class extends Controller {
  static targets = ['item', 'count'];

  initialize() {
    this.player = App.player;
    this.showPlayingItem = this.showPlayingItem.bind(this);
    this._updateCount = this._updateCount.bind(this);
  }

  connect() {
    this.showPlayingItem();
    document.addEventListener('playlistSongs:showPlaying', this.showPlayingItem);
    this.element.addEventListener('playlistSongs:updateCount', this._updateCount);
  }

  disconnect() {
    document.removeEventListener('playlistSongs:showPlaying', this.showPlayingItem);
    this.element.removeEventListener('playlistSongs:updateCount', this._updateCount);
  }

  actionHandler({ target }) {
    switch (target.closest('[data-playlist-songs-action]').dataset.playlistSongsAction) {
      case 'delete':
        this._deleteSong(target);
        break;
      case 'showPlaylistsDialog':
        this._showPlaylistsDialog(target);
        break;
      default:
        this._play(target);
    }
  }

  clear() {
    App.dispatchEvent('#js-playlist-loader', 'loader:show');

    ajax({
      url: `/playlists/${this.playlistId}/song`,
      type: 'delete',
      dataType: 'script',
      data: 'clear_all=true',
      success: () => {
        App.dispatchEvent('#js-playlist-loader', 'loader:hide');

        if (this.isCurrent) {
          this.player.updatePlaylist([]);
          this.player.stop();
        }
      }
    });
  }

  add({ target }) {
    const { playlistId } = target.closest('[data-playlist-id]').dataset;

    App.dispatchEvent('#js-dialog-loader', 'loader:show');

    ajax({
      url: `/playlists/${playlistId}/song`,
      type: 'post',
      data: `song_ids[]=${this.player.selectedSongId}`,
      success: () => {
        App.dispatchEvent('#js-dialog', 'dialog:hide');
      }
    });
  }

  showPlayingItem() {
    this.itemTargets.forEach((element) => {
      element.classList.toggle('list__item--active', element.dataset.songId == this.player.currentSong.id);
    });
  }

  _play(target) {
    const { songId } = target.closest('[data-song-id]').dataset;
    const playlistIndex = this.player.playlistIndexOf(songId);

    if (playlistIndex != -1) {
      this.player.skipTo(playlistIndex);
    } else {
      ajax({
        url: `/playlists/${this.player.currentPlaylistId}/song`,
        type: 'post',
        data: `song_ids[]=${songId}`,
        success: () => {
          this.player.skipTo(this.player.pushToPlaylist(songId));
        }
      });
    }
  }

  _deleteSong(target) {
    const playlistItemElement = target.closest('[data-song-id]');
    const { songId } = playlistItemElement.dataset;

    ajax({
      url: `/playlists/${this.playlistId}/song`,
      type: 'delete',
      dataType: 'script',
      data: `song_ids[]=${songId}`,
      success: () => {
        if (this.isCurrent) { this.player.deleteFromPlaylist(songId); }

        // When already delete all playlist items, use rails ujs to render empty page,
        // avoid to remove item manually.
        if (playlistItemElement) {
          playlistItemElement.remove();
        }
      }
    });
  }

  _showPlaylistsDialog(target) {
    const { songId } = target.closest('[data-song-id]').dataset;
    this.player.selectedSongId = songId;

    App.dispatchEvent('#js-dialog', 'dialog:show');
    App.dispatchEvent('#js-dialog-loader', 'loader:show');

    ajax({
      url: '/dialog/playlists',
      type: 'get',
      dataType: 'script',
      success: () => {
        App.dispatchEvent('#js-dialog-loader', 'loader:hide');
      }
    });
  }

  _updateCount(event) {
    this.countTarget.innerText = event.detail;
  }

  get playlistId() {
    return this.data.get('playlistId');
  }

  get isCurrent() {
    return this.playlistId == this.player.currentPlaylistId;
  }
}
