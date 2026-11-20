export default (songId) => ({
  play () {
    const playlistIndex = this.$store.player.indexOf(songId)

    if (playlistIndex === -1) {
      this.$dispatch('song:request')
    } else {
      this.$store.player.skipTo(playlistIndex)
    }
  },

  get isCurrent () {
    return this.$store.player.currentSong.id === songId
  },

  get isPaused () {
    return this.isCurrent && !this.$store.player.isPlaying
  }
})
