export default {
  renderContent(selector, content) {
    document.querySelector(selector).innerHTML = content;
  },

  dispatchEvent(element, type, data = null) {
    if (typeof element == 'string') { element = document.querySelector(element); }
    element.dispatchEvent(new CustomEvent(type, { detail: data }));
  }
};
