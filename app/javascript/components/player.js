import { formatDuration } from '../helper'

export default () => ({
  progress: 0,
  timer: formatDuration(0),

  init () {
    document.addEventListener('player:beforePlaying', () => {
      this.timer = formatDuration(0)
    })

    document.addEventListener('player:playing', () => {
      window.requestAnimationFrame(() => this.updateProgress())
      this.timerInterval = setInterval(() => this.updateTimer(), 1000)
    })

    document.addEventListener('player:pause', () => this.clearTimerInterval())
    document.addEventListener('player:end', () => this.clearTimerInterval())

    document.addEventListener('player:stop', () => {
      this.clearTimerInterval()

      if (!this.hasCurrentSong) {
        this.progress = 0
        this.timer = formatDuration(0)
      }
    })

    document.addEventListener('player:seek', () => {
      if (this.$store.player.isPlaying) { return }

      this.updateTimer()
      window.requestAnimationFrame(() => this.updateProgress())
    })
  },

  seek (event) {
    this.$store.player.seek((event.offsetX / event.target.offsetWidth) * this.currentSong.duration)
  },

  updateProgress () {
    this.progress = (this.currentTime / this.currentSong.duration) * 100 || 0

    if (this.$store.player.isPlaying) {
      window.requestAnimationFrame(() => this.updateProgress())
    }
  },

  updateTimer () {
    this.timer = formatDuration(this.currentTime)
  },

  clearTimerInterval () {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
  },

  get currentSong () {
    return this.$store.player.currentSong
  },

  get hasCurrentSong () {
    return this.$store.player.hasCurrentSong
  },

  get duration () {
    return this.hasCurrentSong ? formatDuration(this.currentSong.duration) : '--:--'
  },

  get currentTime () {
    return Math.round(this.$store.player.currentTime)
  }
})
