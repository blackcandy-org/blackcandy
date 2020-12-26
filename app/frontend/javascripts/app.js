export default {
  renderContent(selector, content) {
    document.querySelector(selector).innerHTML = content;
  },

  renderPlaylistContent(content) {
    this.renderContent('#js-playlist-content', content);
  },

  appedNextPageContentTo(selector, newContent, nextUrl) {
    document.querySelector(selector).insertAdjacentHTML('beforeend', newContent);
    document.querySelector(selector).closest('[data-infinite-scroll-next-url-value]').dataset.infiniteScrollNextUrlValue = nextUrl;
  },

  dispatchEvent(element, type, data = null) {
    if (typeof element == 'string') { element = document.querySelector(element); }
    element.dispatchEvent(new CustomEvent(type, { detail: data }));
  },

  playlistElement(playlistId) {
    const playlistElement = document.querySelector("#js-playlist-content [data-controller='playlist-songs']");

    if (playlistElement && playlistElement.dataset.playlistSongsPlaylistIdValue == playlistId) {
      return playlistElement;
    }
  },

  dismissOnClick(element) {
    document.addEventListener('click', () => { element.classList.add('u-display-none'); }, { once: true, capture: true });
  },

  renderToDialog(dialogTitle, content) {
    this.renderContent('#js-dialog-content', content);
    this.dispatchEvent('#js-dialog', 'dialog:updateTitle', dialogTitle);
    this.dispatchEvent('#js-dialog', 'dialog:show');
  }
};
