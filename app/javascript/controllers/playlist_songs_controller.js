import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['item']

  static values = {
    isCurrent: Boolean,
    isPlayable: Boolean,
    playlistSongs: Array
  }

  initialize () {
    if (!this.isCurrentValue) { return }

    if (this.hasPlaylistSongsValue) {
      this.player.playlist.update(this.playlistSongsValue)
    }

    if (this.isPlayableValue) {
      this.player.skipTo(0)
    }
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

    switch (actionElement.dataset.submitStartAction) {
      case 'check_before_playing':
        this.#checkBeforePlaying(event)
        break
    }
  }

  submitEndHandle (event) {
    const actionElement = event.target.closest('[data-submit-end-action]')

    if (!actionElement || !event.detail.success) { return }

    switch (actionElement.dataset.submitEndAction) {
      case 'delete':
        this.#delete(event.target)
        break
      case 'play':
        this.#play(event.target)
        break
      case 'add_song':
        this.#addSong(event.target)
        break
      case 'add_song_to_last':
        this.#addSongToLast(event.target)
        break
    }
  }

  clear (event) {
    if (!event.detail.success) { return }
    this.player.playlist.update([])
  }

  #showPlayingItem = () => {
    this.itemTargets.forEach((element) => {
      element.classList.toggle('is-active', Number(element.dataset.songId) === this.player.currentSong.id)
    })
  }

  #checkBeforePlaying (event) {
    if (App.nativeBridge.isTurboNative) { return }

    const { songId } = event.target.closest('[data-song-id]').dataset
    const playlistIndex = this.player.playlist.indexOf(songId)

    if (playlistIndex !== -1) {
      event.detail.formSubmission.stop()
      this.player.skipTo(playlistIndex)
    }
  }

  #play (target) {
    const { songId } = target.closest('[data-song-id]').dataset

    if (App.nativeBridge.isTurboNative) {
      App.nativeBridge.playSong(songId)
    } else {
      this.player.skipTo(this.player.playlist.pushSong(songId))
    }
  }

  #delete (target) {
    const songId = Number(target.closest('[data-song-id]').dataset.songId)

    if (!this.isCurrentValue) { return }

    if (this.player.currentSong.id === songId) {
      this.player.skipTo(this.player.playlist.deleteSong(songId))
    }
  }

  #addSong (target) {
    const { songId } = target.closest('[data-song-id]').dataset
    this.player.playlist.pushSong(songId)
  }

  #addSongToLast (target) {
    const { songId } = target.closest('[data-song-id]').dataset
    this.player.playlist.pushSong(songId, true)
  }

  get player () {
    return App.player
  }
}
