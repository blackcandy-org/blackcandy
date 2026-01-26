import { BridgeComponent } from '@hotwired/hotwire-native-bridge'

export default class extends BridgeComponent {
  static component = 'theme'

  initialize () {
    super.initialize()
    this.send('initialize', { theme: this.element.content })
  }
}
