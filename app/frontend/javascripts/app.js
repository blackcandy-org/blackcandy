export default {
  renderContent(selector, content) {
    document.querySelector(selector).innerHTML = content;
  },

  renderFlash(content) {
    this.renderContent('#js-flash', content);
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

  dispatchEvent(element, type) {
    element.dispatchEvent(new Event(type));
  }
};
