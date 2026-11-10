import 'htmx.org'
import 'htmx.org/dist/ext/hx-alpine-compat.js'
import Alpine from 'alpinejs'
import './components'
import './controllers'

import Player from './player'

window.App = {
  player: new Player()
}

window.Alpine = Alpine
Alpine.start()
