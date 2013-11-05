window.pizzabuttonapp =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Config: 
    pizza_types: [
        type: 'cheese'
        friendly_name: 'Cheese'
      ,
        type: 'pepperonni'
        friendly_name: 'Pepperonni'
    ]
    pizza_sizes: [
        code: 'S'
        friendly_name: 'Small'
      ,
        code: 'M'
        friendly_name: 'Medium'
      ,
        code: 'L'
        friendly_name: 'Large'
      ,
        code: 'XL'
        friendly_name: 'Extra-Large'
    ]
  init: ->
    'use strict'
    routes = new pizzabuttonapp.Routers.AppRouter
    Backbone.history.start()

$ ->
  'use strict'
  pizzabuttonapp.init();
