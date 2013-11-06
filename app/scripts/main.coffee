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

class ensureAndWaitFor
  constructor: (opts) ->
    required_opts = ['continue', 'continue_when', 'give_up']

    for opt_name in required_opts
      throw "Can't EnsureAndWaitFor without the #{opt_name} option!" unless opts[opt_name]?
      @[opt_name] = opts[opt_name]

    # not required
    @message = opts['message']
    @timeout = opts['timeout'] || 3     # max time user will see a spinner before we give up

    @go()

  go: ->
    seconds_to_wait  = @timeout
    poll_interval_ms = 100
    poll_counter     = 0

    poll = =>
      if @continue_when()
        @continue()
      else if poll_counter * poll_interval_ms / 1000 < seconds_to_wait
        poll_counter++
        setTimeout poll, poll_interval_ms
      else
        # Give up
        @give_up()

    if @continue_when()
      @continue()
    else
      waiting_view = new pizzabuttonapp.Views.WaitingView
        message: @message
      waiting_view.render()
      poll()

$ ->
  'use strict'
  pizzabuttonapp.init();
