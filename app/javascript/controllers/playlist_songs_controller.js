import { Controller } from '@hotwired/stimulus'
import { camelCase } from '../helper'

export default class extends Controller {
  static targets = ['item']

  submitStartActions = []
  clickActions = []

  initialize () {
    this.submitStartActions = ['checkBeforePlaying', 'checkCurrentSong']
  }

  connect () {
    this.#showPlayingItem()
    document.addEventListener('playlistSongs:showPlaying', this.#showPlayingItem)
  }

  disconnect () {
    document.removeEventListener('playlistSongs:showPlaying', this.#showPlayingItem)
  }

  submitStartHandle (event) {
    const actionElement = event.target.closest('[data-submit-start-action]')
    if (!actionElement) { return }

    const actionName = camelCase(actionElement.dataset.submitStartAction)
    if (!this.submitStartActions.includes(actionName)) { return }

    this[`_${actionName}`](event)
  }

  clickHandle (event) {
    const actionElement = event.target.closest('[data-click-action]')
    if (!actionElement) { return }

    const actionName = camelCase(actionElement.dataset.clickAction)
    if (!this.clickActions.includes(actionName)) { return }

    this[`_${actionName}`](event.target)
  }

  _checkBeforePlaying (event) {
    const { songId } = event.target.closest('[data-song-id]').dataset

    if (App.nativeBridge.isTurboNative) {
      event.detail.formSubmission.stop()
      App.nativeBridge.playSong(songId)

      return
    }

    const playlistIndex = this.player.playlist.indexOf(songId)

    if (playlistIndex !== -1) {
      event.detail.formSubmission.stop()
      this.player.skipTo(playlistIndex)
    } else {
      this._checkCurrentSong(event)
    }
  }

  _checkCurrentSong (event) {
    const currentSongId = this.player.currentSong.id

    if (currentSongId !== undefined) {
      event.detail.formSubmission.fetchRequest.body.append('current_song_id', currentSongId)
    }
  }

  #showPlayingItem = () => {
    this.itemTargets.forEach((element) => {
      element.classList.toggle('is-active', Number(element.dataset.songId) === this.player.currentSong.id)
    })
  }

  get player () {
    return App.player
  }
}
