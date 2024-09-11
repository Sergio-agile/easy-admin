# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# pin "bootstrap", to: "bootstrap.min.js"
# pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.3.2/dist/js/bootstrap.esm.js"
# pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/lib/index.js"
pin "popper", to: 'popper.js', preload: true
pin "bootstrap", to: 'bootstrap.min.js', preload: true
# pin "@fortawesome/fontawesome-free", to: "@fortawesome--fontawesome-free.js" # @6.6.0
pin '@fortawesome/fontawesome-free', to: 'https://ga.jspm.io/npm:@fortawesome/fontawesome-free@6.1.1/js/all.js'
 pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
