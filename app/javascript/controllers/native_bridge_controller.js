import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  initialize () {
    installEventHandler(this)
  }

  connect () {
    this.handleEvent('click', {
      on: this.element,
      matching: `[data-delegated-action~='${this.scope.identifier}#playSong']`,
      with: this.playSong
    })

    this.handleEvent('click', {
      on: this.element,
      matching: `[data-delegated-action~='${this.scope.identifier}#playNext']`,
      with: this.playNext
    })

    this.handleEvent('click', {
      on: this.element,
      matching: `[data-delegated-action~='${this.scope.identifier}#playLast']`,
      with: this.playLast
    })
  }

  playAll ({ params }) {
    App.nativeBridge.playAll(params.resourceType, params.resourceId)
  }

  playSong (event) {
    const { songId } = event.target.closest('[data-song-id]').dataset
    App.nativeBridge.playSong(songId)
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
