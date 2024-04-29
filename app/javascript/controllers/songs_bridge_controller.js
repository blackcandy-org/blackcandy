import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'
import { isNativeApp } from '../helper'

export default class extends Controller {
  static get shouldLoad () {
    return isNativeApp()
  }

  initialize () {
    installEventHandler(this)
  }

  connect () {
    this.handleEvent('click', {
      on: this.element,
      with: this.playNow,
      delegation: true
    })

    this.handleEvent('click', {
      on: this.element,
      with: this.playNext,
      delegation: true
    })

    this.handleEvent('click', {
      on: this.element,
      with: this.playLast,
      delegation: true
    })
  }

  playNow (event) {
    const { songId } = event.target.closest('[data-song-id]').dataset
    App.nativeBridge.playNow(songId)
  }

  playNext (event) {
    const { songId } = event.target.closest('[data-song-id]').dataset
    App.nativeBridge.playNext(songId)
  }

  playLast (event) {
    const { songId } = event.target.closest('[data-song-id]').dataset
    App.nativeBridge.playLast(songId)
  }
}
