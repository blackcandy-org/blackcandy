import '@hotwired/turbo-rails'
import './controllers'

import Player from './player'
import NativeBridge from './native_bridge'

window.App = { player: new Player() }
window.NativeBridge = new NativeBridge()
