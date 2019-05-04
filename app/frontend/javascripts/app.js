import Noty from 'noty';

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
