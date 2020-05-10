export default {
  renderContent(selector, content) {
    document.querySelector(selector).innerHTML = content;
  },

  renderPlaylistContent(content) {
    this.renderContent('#js-playlist-content', content);
  },

  appedNextPageContentTo(selector, newContent, nextUrl) {
    document.querySelector(selector).insertAdjacentHTML('beforeend', newContent);
    document.querySelector(selector).closest('[data-infinite-scroll-next-url]').dataset.infiniteScrollNextUrl = nextUrl;
  },

  dispatchEvent(element, type, data = null) {
    if (typeof element == 'string') { element = document.querySelector(element); }
    element.dispatchEvent(new CustomEvent(type, { detail: data }));
  },

  playlistElement(playlistId) {
    const playlistElement = document.querySelector("#js-playlist-content [data-controller='playlist-songs']");

    if (playlistElement && playlistElement.dataset.playlistSongsPlaylistId == playlistId) {
      return playlistElement;
    }
  }
};
