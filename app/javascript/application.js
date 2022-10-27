import '@hotwired/turbo-rails'
import './controllers'
import './channels'

import Player from './player'
import NativeBridge from './native_bridge'

window.App = { player: new Player() }
window.NativeBridge = new NativeBridge()

window.NativeBridge.updateTheme(document.body.dataset.colorScheme)
