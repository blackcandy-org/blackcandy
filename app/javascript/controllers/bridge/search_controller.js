import { BridgeComponent } from '@hotwired/hotwire-native-bridge'

export default class extends BridgeComponent {
  static component = 'search'
  static targets = ['input']

  connect () {
    super.connect()

    this.send('connect', {}, ({ data }) => {
      const query = data.query

      this.inputTarget.value = query
      this.element.submit()
    })
  }
}
