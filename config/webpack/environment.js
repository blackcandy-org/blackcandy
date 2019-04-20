const { environment } = require('@rails/webpacker')

environment.loaders.delete('nodeModules')
module.exports = environment
