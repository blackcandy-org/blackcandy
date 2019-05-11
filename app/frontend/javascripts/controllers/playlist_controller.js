import { Controller } from 'stimulus';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = ['item', 'count'];

  initialize() {
    this.player = App.player;
    this.showPlayingItem = this.showPlayingItem.bind(this);
    this._updateCount = this._updateCount.bind(this);
  }

  connect() {
    this.showPlayingItem();
    document.addEventListener('show.playingitem', this.showPlayingItem);
    this.element.addEventListener('updateCount', this._updateCount);
  }

  disconnect() {
    document.removeEventListener('show.playingitem', this.showPlayingItem);
    this.element.removeEventListener('updateCount', this._updateCount);
  }

  actionHandler({ target }) {
    switch (target.closest('[data-playlist-action]').dataset.playlistAction) {
      case 'delete':
        this._deleteSong(target);
        break;
      case 'showCollectionDialog':
        this._showCollectionDialog(target);
        break;
      default:
        this._play(target);
    }
  }

  playAll() {
    ajax({
      url: this.data.get('playPath'),
      type: 'post',
      dataType: 'script'
    });
  }

  clear() {
    App.dispatchEvent('#js-playlist-loader', 'show.loader');

    ajax({
      url: `/playlist/${this.id}`,
      type: 'delete',
      dataType: 'script',
      success: () => {
        App.dispatchEvent('#js-playlist-loader', 'hide.loader');

        if (this.isCurrent) {
          this.player.updatePlaylist([]);
          this.player.stop();
        }
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
        url: '/playlist/current',
        type: 'put',
        data: `update_action=push&song_id=${songId}`,
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
      url: `/playlist/${this.id}`,
      type: 'put',
      dataType: 'script',
      data: `update_action=delete&song_id=${songId}`,
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

  _showCollectionDialog(target) {
    const { songId } = target.closest('[data-song-id]').dataset;

    App.dispatchEvent('#js-dialog', 'show.dialog');
    App.dispatchEvent('#js-dialog-loader', 'show.loader');

    ajax({
      url: `/songs/${songId}/add`,
      type: 'get',
      dataType: 'script',
      success: () => {
        App.dispatchEvent('#js-dialog-loader', 'hide.loader');
      }
    });
  }

  _updateCount(event) {
    this.countTarget.innerText = event.detail;
  }

  get id() {
    return this.data.get('id');
  }

  get isCurrent() {
    return this.id == 'current';
  }
}
