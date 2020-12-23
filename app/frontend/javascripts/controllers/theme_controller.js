import { Controller } from 'stimulus';

export default class extends Controller {
  static values = {
    name: String
  }

  initialize() {
    this._updateTheme();
  }

  nameValueChanged() {
    this._updateTheme();
  }

  _updateTheme = () => {
    if (this.colorSchemeQuery) { this.colorSchemeQuery.removeListener(this._matchTheme); }

    const oneYearFromNow = new Date(Date.now() + 365 * 864e5).toUTCString();

    // set theme cookie to track theme when user didn't login
    document.cookie = `theme=${this.nameValue};path=/;samesite=lax;expires=${oneYearFromNow}`;

    switch (this.nameValue) {
      case 'dark':
        this._setDarkTheme();
        break;
      case 'auto':
        this._setAutoTheme();
        break;
      default:
        this._setLightTheme();
    }
  }

  _matchTheme = (event) => {
    if (event.matches) {
      this._setDarkTheme();
    } else {
      this._setLightTheme();
    }
  }

  _setAutoTheme() {
    this.colorSchemeQuery = window.matchMedia('(prefers-color-scheme: dark)');
    this._matchTheme(this.colorSchemeQuery);
    this.colorSchemeQuery.addListener(this._matchTheme);
  }

  _setDarkTheme() {
    document.documentElement.setAttribute('data-color-scheme', 'dark');
  }

  _setLightTheme() {
    document.documentElement.removeAttribute('data-color-scheme');
  }
}
