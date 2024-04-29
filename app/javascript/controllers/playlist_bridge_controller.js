import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'
import { isNativeApp } from '../helper'

export default class extends Controller {
  static get shouldLoad () {
    return isNativeApp()
  }

  static values = {
    id: Number
  }

  initialize () {
    installEventHandler(this)
  }

  connect () {
    this.handleEvent('click', {
      on: this.element,
      with: this.playBeginWith,
      delegation: true
    })
  }

  play () {
    App.nativeBridge.playPlaylist(this.idValue)
  }

  playBeginWith = (event) => {
    const { songId } = event.target.closest('[data-song-id]').dataset
    App.nativeBridge.playPlaylistBeginWith(this.idValue, songId)
  }
}
