import PlaylistSongsController from './playlist_songs_controller.js'

export default class extends PlaylistSongsController {
  static values = {
    isPlayable: Boolean,
    playlistSongs: Array
  }

  submitStartActions = []
  submitEndActions = ['delete']
  clickActions = ['play']

  initialize () {
    super.initialize()

    if (this.hasPlaylistSongsValue) {
      this.player.playlist.update(this.playlistSongsValue)
    }

    if (this.isPlayableValue) {
      this.player.skipTo(0)
    }
  }

  clear (event) {
    if (!event.detail.success) { return }
    this.player.playlist.update([])
  }

  _play (target) {
    const { songId } = target.closest('[data-song-id]').dataset
    const playlistIndex = this.player.playlist.indexOf(songId)

    this.player.skipTo(playlistIndex)
  }

  _delete (target) {
    const songId = Number(target.closest('[data-song-id]').dataset.songId)

    if (this.player.currentSong.id === songId) {
      this.player.skipTo(this.player.playlist.deleteSong(songId))
    }
  }
}
