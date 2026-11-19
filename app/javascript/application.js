import 'htmx.org'
import 'htmx.org/dist/ext/hx-alpine-compat.js'
import Alpine from 'alpinejs'
import './stores'
import './components'
import './controllers'

window.Alpine = Alpine
Alpine.start()
