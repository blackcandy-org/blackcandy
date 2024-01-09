import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'
import { installPlayingSongIndicator } from './mixins/playing_song_indicator'

export default class extends Controller {
  static targets = ['item']

  static values = {
    shouldPlayAll: Boolean
  }

  initialize () {
    installEventHandler(this)
    installPlayingSongIndicator(this, () => this.itemTargets)
  }

  itemTargetConnected (target) {
    const song = JSON.parse(target.dataset.songJson)
    const shouldPlay = target.dataset.shouldPlay === 'true'
    const targetIndex = this.itemTargets.indexOf(target)

    this.playlist.insert(targetIndex, song)

    if (shouldPlay) {
      this.player.skipTo(targetIndex)
      delete target.dataset.shouldPlay
    }
  }

  connect () {
    if (this.shouldPlayAllValue) {
      this.player.skipTo(0)
      this.shouldPlayAllValue = false
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

    this.playlist.deleteSong(songId)

    if (this.player.currentSong.id === songId && !targetIsDragging) {
      this.player.stop()
    }
  }

  play = (event) => {
    const { songId } = event.target.closest('[data-song-id]').dataset
    const playlistIndex = this.playlist.indexOf(songId)

    this.player.skipTo(playlistIndex)
  }

  get player () {
    return App.player
  }

  get playlist () {
    return this.player.playlist
  }
}
