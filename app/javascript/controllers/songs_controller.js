import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'
import { installPlayingSongIndicator } from './mixins/playing_song_indicator'
import { isNativeApp } from '../helper'

export default class extends Controller {
  static get shouldLoad () {
    return !isNativeApp()
  }

  static targets = ['item']

  initialize () {
    installEventHandler(this)
    installPlayingSongIndicator(this, () => this.itemTargets)
  }

  connect () {
    this.handleEvent('turbo:submit-start', {
      on: this.element,
      with: this.checkBeforePlay,
      delegation: true
    })

    this.handleEvent('turbo:submit-start', {
      on: this.element,
      with: this.checkBeforePlayNext,
      delegation: true
    })
  }

  checkBeforePlay = (event) => {
    const { songId } = event.target.closest('[data-song-id]').dataset
    const playlistIndex = this.player.playlist.indexOf(songId)

    if (playlistIndex !== -1) {
      event.detail.formSubmission.stop()
      this.player.skipTo(playlistIndex)
    } else {
      this.#appendCurrentSongIdToSubmission(event)
    }
  }

  checkBeforePlayNext = (event) => {
    this.#appendCurrentSongIdToSubmission(event)
  }

  #appendCurrentSongIdToSubmission (event) {
    const currentSongId = this.player.currentSong.id

    if (currentSongId !== undefined) {
      event.detail.formSubmission.fetchRequest.body.append('current_song_id', currentSongId)
    }
  }

  get player () {
    return App.player
  }
}
