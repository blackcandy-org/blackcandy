import PlaylistSongsController from './playlist_songs_controller.js'

export default class extends PlaylistSongsController {
  static values = {
    shouldPlayAll: Boolean
  }

  initialize () {
    this.clickActions = ['play']
  }

  itemTargetConnected (target) {
    const song = JSON.parse(target.dataset.songJson)
    const shouldPlay = target.dataset.shouldPlay === 'true'
    const targetIndex = this.itemTargets.indexOf(target)

    if (this.player.playlist.indexOf(song.id) !== -1) { return }

    this.player.playlist.insert(targetIndex, song)

    if (shouldPlay) {
      this.player.skipTo(targetIndex)
      delete target.dataset.shouldPlay
    }
  }

  connect () {
    super.connect()

    if (this.shouldPlayAllValue) {
      this.player.skipTo(0)
      this.shouldPlayAllValue = false
    }
  }

  itemTargetDisconnected (target) {
    const songId = Number(target.dataset.songId)

    if (this.player.playlist.indexOf(songId) === -1) { return }

    const deleteSongIndex = this.player.playlist.deleteSong(songId)

    if (this.player.currentSong.id === songId) {
      this.player.skipTo(deleteSongIndex)
    }
  }

  _play (target) {
    const { songId } = target.closest('[data-song-id]').dataset
    const playlistIndex = this.player.playlist.indexOf(songId)

    this.player.skipTo(playlistIndex)
  }
}
