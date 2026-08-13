import { Controller } from '@hotwired/stimulus'
import { installEventHandler } from './mixins/event_handler'

const RESUME_FOLLOWING_DELAY = 4000

export default class extends Controller {
  static targets = ['line']

  initialize () {
    this.activeLine = null
    this.isSyncing = false
    this.isFollowing = true

    installEventHandler(this)
  }

  connect () {
    this.handleEvent('player:playing', { with: this.#startSync })
    this.handleEvent('player:seek', { with: this.#updateActiveLine })
    this.handleEvent('lyrics:show', { with: this.#show })

    this.#updateActiveLine()
    this.#startSync()
  }

  disconnect () {
    clearTimeout(this.resumeFollowingTimer)
  }

  seek ({ target }) {
    if (!this.#isSynced || !this.lineTargets.includes(target)) { return }

    this.player.seek(Number(target.dataset.time))
  }

  suspendFollowing () {
    this.isFollowing = false
    clearTimeout(this.resumeFollowingTimer)
    this.resumeFollowingTimer = setTimeout(this.#resumeFollowing, RESUME_FOLLOWING_DELAY)
  }

  get player () {
    return App.player
  }

  get #isSynced () {
    return this.lineTargets[0]?.dataset.time !== undefined
  }

  get #shouldSync () {
    return this.element.isConnected && this.player.isPlaying && this.#isSynced
  }

  #show = () => {
    clearTimeout(this.resumeFollowingTimer)

    this.#resumeFollowing()
    this.#startSync()
  }

  #startSync = () => {
    if (this.isSyncing || !this.#shouldSync) { return }

    this.isSyncing = true
    window.requestAnimationFrame(this.#sync)
  }

  #sync = () => {
    if (!this.#shouldSync) {
      this.isSyncing = false
      return
    }

    this.#updateActiveLine()
    window.requestAnimationFrame(this.#sync)
  }

  #updateActiveLine = () => {
    if (!this.#isSynced) { return }

    const { currentTime } = this.player
    const activeLine = this.lineTargets.findLast((line) => Number(line.dataset.time) <= currentTime) ?? null

    if (activeLine === this.activeLine) { return }

    this.activeLine?.classList.remove('is-active')
    activeLine?.classList.add('is-active')
    this.activeLine = activeLine

    if (this.isFollowing) { this.#scrollToActiveLine() }
  }

  #scrollToActiveLine () {
    const { activeLine, element } = this
    const top = activeLine ? activeLine.offsetTop - (element.clientHeight - activeLine.clientHeight) / 2 : 0

    element.scrollTo({ top })
  }

  #resumeFollowing = () => {
    this.isFollowing = true
    this.#scrollToActiveLine()
  }
}
