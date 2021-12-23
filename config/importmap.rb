# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "howler" # @2.2.3
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@shopify/draggable", to: "@shopify--draggable.js" # @1.0.0
