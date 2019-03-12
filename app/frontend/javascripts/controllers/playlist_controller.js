import { Controller } from 'stimulus';
import { ajax } from 'rails-ujs';

export default class extends Controller {
  static targets = ['item'];

  initialize() {
    this.player = App.player;
  }

  connect() {
    this.showPlayingItem();
  }

  play({ target }) {
    const { songId } = target.closest('.playlist__item').dataset;
    const playlistIndex = this.player.playlistIndexOf(songId);

    if (playlistIndex != -1) {
      this.player.skipTo(playlistIndex);
    } else {
      ajax({
        url: '/playlist/current',
        type: 'put',
        dataType: 'script',
        data: `update_action=push&song_ids[]=${songId}`,
        success: () => {
          this.player.skipTo(this.player.pushToPlaylist(songId));
        }
      });
    }
  }

  showPlayingItem() {
    this.itemTargets.forEach((element) => {
      element.classList.toggle('playlist__item--active', element.dataset.songId == this.player.currentSong.id);
    });
  }
}
