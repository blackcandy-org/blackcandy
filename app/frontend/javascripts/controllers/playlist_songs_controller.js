import { Controller } from 'stimulus';
import { ajax } from '@rails/ujs';

export default class extends Controller {
  static targets = ['item', 'count', 'playAllLink'];

  static values = {
    playlistId: Number,
    isCurrent: Boolean
  }

  initialize() {
    this.player = App.player;
  }

  connect() {
    this._showPlayingItem();
    document.addEventListener('playlistSongs:showPlaying', this._showPlayingItem);
    this.element.addEventListener('playlistSongs:updateCount', this._updateCount);
    this.element.addEventListener('playlistSongs:updatePlayAllLink', this._updatePlayAllLink);
  }

  disconnect() {
    document.removeEventListener('playlistSongs:showPlaying', this._showPlayingItem);
    this.element.removeEventListener('playlistSongs:updateCount', this._updateCount);
    this.element.removeEventListener('playlistSongs:updatePlayAllLink', this._updatePlayAllLink);
  }

  actionHandler({ target }) {
    const actionElement = target.closest('[data-playlist-songs-action]');

    if (!actionElement) { return; }

    switch (actionElement.dataset.playlistSongsAction) {
      case 'delete':
        this._deleteSong(target);
        break;
      case 'showMenu':
        this._showMenu(target);
        break;
      case 'play':
        this._play(target);
        break;
      case 'none':
        break;
    }
  }

  clear() {
    App.dispatchEvent('#js-playlist-loader', 'loader:show');

    ajax({
      url: `/playlists/${this.playlistIdValue}/songs`,
      type: 'delete',
      dataType: 'script',
      data: 'clear_all=true',
      success: () => {
        App.dispatchEvent('#js-playlist-loader', 'loader:hide');

        if (this.isCurrentValue) {
          this.player.playlist.update([]);
          this.player.stop();
        }
      }
    });
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

  _deleteSong(target) {
    const playlistItemElement = target.closest('[data-song-id]');
    const { songId } = playlistItemElement.dataset;

    ajax({
      url: `/playlists/${this.playlistIdValue}/songs`,
      type: 'delete',
      dataType: 'script',
      data: `song_ids[]=${songId}`,
      success: () => {
        if (this.isCurrentValue) {
          const songIndex = this.player.playlist.deleteSong(songId);
          if (this.player.currentSong.id == songId) { this.player.skipTo(songIndex); }
        }

        // When already delete all playlist items, use rails ujs to render empty page,
        // avoid to remove item manually.
        if (playlistItemElement) {
          playlistItemElement.remove();
        }
      }
    });
  }

  _showMenu(target) {
    const menuListElement = target.closest('.js-playlist-songs-menu').querySelector('.js-playlist-songs-menu-list');

    menuListElement.classList.remove('u-display-none');
    App.dismissOnClick(menuListElement);
  }

  _updateCount = (event) => {
    this.countTarget.innerText = event.detail;
  }

  _updatePlayAllLink = (event) => {
    if (this.hasPlayAllLinkTarget) {
      this.playAllLinkTarget.href = event.detail;
    }
  }
}
