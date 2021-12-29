import '@hotwired/turbo-rails';
import './controllers';

import Player from './player';

window.App = { player: new Player() };
