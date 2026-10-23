import '@hotwired/turbo-rails'
import 'htmx.org'
import './lib/turbo_bridge'
import './controllers'

import Player from './player'

window.App = {
  player: new Player()
}
