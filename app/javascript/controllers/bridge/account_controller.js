import { BridgeComponent, BridgeElement } from '@hotwired/hotwire-native-bridge'

export default class extends BridgeComponent {
  static component = 'account'
  static targets = ['menuItem']

  connect () {
    super.connect()
    this.send('connect')
  }

  menuItemTargetConnected (target) {
    const menuItem = new BridgeElement(target)
    const menuId = menuItem.bridgeAttribute('id')

    this.send(`menuItemConnected:${menuId}`, {}, () => {
      target.click()
    })
  }
}
