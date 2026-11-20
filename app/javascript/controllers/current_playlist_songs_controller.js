import { Controller } from '@hotwired/stimulus'
import Alpine from 'alpinejs'
import { installEventHandler } from './mixins/event_handler'

export default class extends Controller {
  static targets = ['item']

  static values = {
    shouldPlay: Boolean
  }

  initialize () {
    installEventHandler(this)
  }

  itemTargetConnected (target) {
    const song = JSON.parse(target.dataset.songJson)
    const songShouldPlay = target.dataset.shouldPlay === 'true'
    const targetIndex = this.itemTargets.indexOf(target)

    this.player.insertSong(targetIndex, song)

    if (songShouldPlay) {
      this.player.skipTo(targetIndex)

      delete target.dataset.shouldPlay
      this.shouldPlayValue = false
    }
  }

  connect () {
    if (this.shouldPlayValue) {
      // If no particular song is set to play, play the first song
      this.player.skipTo(0)
      this.shouldPlayValue = false
    }

    this.handleEvent('click', {
      on: this.element,
      with: this.play,
      delegation: true
    })
  }

  itemTargetDisconnected (target) {
    const songId = Number(target.dataset.songId)
    const targetIsDragging = target.classList.contains('is-dragging-source')

    this.player.deleteSong(songId)

    if (this.player.currentSong.id === songId && !targetIsDragging) {
      this.player.stop()
    }
  }

  play = (event) => {
    const { songId } = event.target.closest('[data-song-id]').dataset
    const playlistIndex = this.player.indexOf(songId)

    this.player.skipTo(playlistIndex)
  }

  get player () {
    return Alpine.store('player')
  }
}
