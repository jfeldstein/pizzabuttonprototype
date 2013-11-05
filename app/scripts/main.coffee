window.pizzabuttonapp =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    'use strict'
    routes = new pizzabuttonapp.Routers.AppRouter
    Backbone.history.start()

$ ->
  'use strict'
  pizzabuttonapp.init();
