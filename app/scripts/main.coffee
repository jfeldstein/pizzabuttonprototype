window.pizzabuttonapp =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  State: {}
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

    getLocation (loc) =>
      @State.location = loc

# Put phonegap location implementation here
getLocation = (cb) ->
  #stub, just return a dummy value
  cb
    zip: 94131

$ ->
  'use strict'
  pizzabuttonapp.init();
