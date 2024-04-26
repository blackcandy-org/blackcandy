import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'
import { isNativeApp } from '../helper'

export default class extends Controller {
  static get shouldLoad () {
    return isNativeApp()
  }

  static values = {
    resourceType: String,
    resourceId: Number
  }

  initialize () {
    installEventHandler(this)
  }

  connect () {
    this.handleEvent('click', {
      on: this.element,
      with: this.playResourceBeginWith,
      delegation: true
    })

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

  playResource () {
    App.nativeBridge.playResource(this.resourceTypeValue, this.resourceIdValue)
  }

  playResourceBeginWith = (event) => {
    const { songId } = event.target.closest('[data-song-id]').dataset
    App.nativeBridge.playResourceBeginWith(this.resourceTypeValue, this.resourceIdValue, songId)
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
