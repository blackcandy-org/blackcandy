import { BridgeComponent } from '@hotwired/hotwire-native-bridge'

export default class extends BridgeComponent {
  static component = 'flash'

  connect () {
    super.connect()
    this.send('connect', { message: this.element.textContent.trim() })
  }
}
