import { BridgeComponent } from '@hotwired/hotwire-native-bridge'
import { installEventHandler } from '../mixins/event_handler'

export default class extends BridgeComponent {
  static component = 'songs'

  initialize () {
    installEventHandler(this)
  }

  connect () {
    super.connect()

    this.handleEvent('click', {
      on: this.element,
      with: this.playNow,
      delegation: true
    })

    this.handleEvent('click', {
      on: this.element,
      with: this.playNext,
      delegation: true
    })

    this.handleEvent('click', {
      on: this.element,
      with: this.playLast,
      delegation: true
    })
  }

  playNow = (event) => {
    const songId = Number(event.target.closest('[data-song-id]').dataset.songId)
    this.send('playNow', { songId })
  }

  playNext = (event) => {
    const songId = Number(event.target.closest('[data-song-id]').dataset.songId)
    this.send('playNext', { songId })
  }

  playLast = (event) => {
    const songId = Number(event.target.closest('[data-song-id]').dataset.songId)
    this.send('playLast', { songId })
  }
}
