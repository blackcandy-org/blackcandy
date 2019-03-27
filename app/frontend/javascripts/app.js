import Noty from 'noty';

export default {
  renderContent(selector, content) {
    document.querySelector(selector).innerHTML = content;
  },

  renderPlaylistContent(content) {
    this.renderContent('#js-playlist-content', content);
  },

  appendPlaylistNewContentTo(selector, newPlaylistContent) {
    const oldContent = document.querySelector(selector).innerHTML;

    this.renderPlaylistContent(newPlaylistContent);
    document.querySelector(selector).insertAdjacentHTML('afterbegin', oldContent);
  },

  appendAlbumNewContentTo(selector, newAlbumContent) {
    const oldContent = document.querySelector(selector).innerHTML;

    this.renderContent('#js-albums-container', newAlbumContent);
    document.querySelector(selector).insertAdjacentHTML('afterbegin', oldContent);
  },

  appendArtistNewContentTo(selector, newAlbumContent) {
    const oldContent = document.querySelector(selector).innerHTML;

    this.renderContent('#js-artists-container', newAlbumContent);
    document.querySelector(selector).insertAdjacentHTML('afterbegin', oldContent);
  },

  appendPlaylistDialogNewContentTo(selector, newPlaylistDialogContent) {
    const oldContent = document.querySelector(selector).innerHTML;

    this.renderContent('#js-playlist-dialog-content', newPlaylistDialogContent);
    document.querySelector(selector).insertAdjacentHTML('afterbegin', oldContent);
  },

  dispatchEvent(element, type) {
    if (typeof element == 'string') { element = document.querySelector(element); }
    element.dispatchEvent(new Event(type));
  },

  showNotification(text, type) {
    const types = ['success', 'error'];

    new Noty({
      text,
      type: types.includes(type) ? type : 'success',
      timeout: 2500,
      progressBar: false,
      container: '#js-flash'
    }).show();
  }
};
