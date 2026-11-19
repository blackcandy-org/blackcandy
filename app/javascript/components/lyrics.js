export default () => ({
  lyricsOpen: false,

  init () {
    this.$watch('lyricsOpen && $store.player.currentSong.lyrics_url', (lyricsUrl) => this.loadLyrics(lyricsUrl))
  },

  toggleLyrics () {
    this.lyricsOpen = !this.lyricsOpen

    if (this.lyricsOpen) { this.$dispatch('lyrics:show') }
  },

  loadLyrics (lyricsUrl) {
    if (!lyricsUrl || this.loadedLyricsUrl === lyricsUrl) { return }

    this.loadedLyricsUrl = lyricsUrl
    this.$dispatch('lyrics:load')
  }
})
