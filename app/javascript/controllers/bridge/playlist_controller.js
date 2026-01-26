import { BridgeComponent } from '@hotwired/hotwire-native-bridge'
import { installEventHandler } from '../mixins/event_handler'

export default class extends BridgeComponent {
  static component = 'playlist'

  static values = {
    id: Number
  }

  initialize () {
    installEventHandler(this)
  }

  connect () {
    super.connect()

    this.handleEvent('click', {
      on: this.element,
      with: this.playBeginWith,
      delegation: true
    })
  }

  play () {
    this.send('play', { playlistId: this.idValue })
  }

  playBeginWith = (event) => {
    const { songId } = event.target.closest('[data-song-id]').dataset
    this.send('playBeginWith', { playlistId: this.idValue, songId })
  }
}
