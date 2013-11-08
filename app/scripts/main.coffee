window.pizzabuttonapp =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  State: {}
  Config: 
    service_fee: 1
    pizza_types: [
        id: 'cheese'
        friendly_name: 'Cheese'
      ,
        id: 'pepperonni'
        friendly_name: 'Pepperonni'
    ]
    pizza_sizes: [
        id: 'S'
        friendly_name: 'Small'
      ,
        id: 'M'
        friendly_name: 'Medium'
      ,
        id: 'L'
        friendly_name: 'Large'
      ,
        id: 'XL'
        friendly_name: 'Extra-Large'
    ]
  init: ->
    'use strict'
    
    routes = new pizzabuttonapp.Routers.AppRouter

    # TODO: Have the user stay logged in between app-loads
    pizzabuttonapp.State.user = getUserForAppState()

    pizzabuttonapp.State.order = new pizzabuttonapp.Models.OrderModel
      customer: pizzabuttonapp.State.user

    getLocation (loc) =>
      @State.location = loc
      getRestaurants (restaurants) =>
        if restaurants.length > 0
          @State.restaurants = restaurants
          @State.order.set_restaurant restaurants[0]

    Backbone.history.start()

# Put phonegap location implementation here
getLocation = (cb) ->
  #stub, just return a dummy value
  cb
    zip: '94131'
    state: 'CA'
    city: 'San Francisco'

getUserForAppState = -> 
  # Fetch related compenents to get started with user. 

  if current_user = Parse.User.current()
    current_user.fetch_related()
  else
    current_user = new Parse.User
      username: randomString 40
      password: randomString 40

    # TODO: Figure out some way to handle errors when creating these anonymous users.
    current_user.signUp
      success: ->
        current_user.fetch_related()
      error: ->
        console.error "FAILURE FETCHING USER", arguments

  current_user


window.randomString = (len, charSet) ->
    charSet ||= 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    randomString = ''
    i=0
    while i < len
      randomPoz = Math.floor(Math.random() * charSet.length)
      randomString += charSet.substring(randomPoz,randomPoz+1)
      i++

    randomString

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
