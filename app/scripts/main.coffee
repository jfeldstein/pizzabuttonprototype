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
      getRestaurants (restaurants) =>
        @State.restaurants = restaurants if restaurants.length > 0

# Put phonegap location implementation here
getLocation = (cb) ->
  #stub, just return a dummy value
  cb
    zip: 94131

getRestaurants = (cb) -> 
  #stub, return either one restaurant:
  cb [
    name: "Pappa Johns"
    phone: '8472824467'
    menu:
      cheese:
        S: 9
        M: 11
        L: 13
        XL: 16
      pepperonni:
        S: 10
        M: 12
        L: 14
        XL: 17
    location:
      lat: -127.1234
      lon: 32.4321
      address:
        street: "123 Pizza Lane"
        city: "Buffalo Grove"
        state: "IL"
        zip: "60089"
  ]
  #or multiple:
  #
  #or none:
  #cb([])

class window.ensureAndWaitFor
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

    console.log "Continue when", @continue_when, @continue_when()

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
