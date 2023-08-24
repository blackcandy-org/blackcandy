import PlaylistSongsController from './playlist_songs_controller.js'

export default class extends PlaylistSongsController {
  static values = {
    playable: Boolean
  }

  initialize () {
    this.clickActions = ['play']
  }

  itemTargetConnected (target) {
    const song = JSON.parse(target.dataset.songJson)
    const songPlayable = target.dataset.songPlayable === 'true'
    const targetIndex = this.itemTargets.indexOf(target)

    if (this.player.playlist.indexOf(song.id) !== -1) { return }

    this.player.playlist.insert(targetIndex, song)

    if (songPlayable) {
      this.player.skipTo(targetIndex)
    }
  }

  connect () {
    super.connect()

    if (this.playableValue) {
      this.player.skipTo(0)
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
