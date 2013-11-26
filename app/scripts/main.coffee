
# console = new Object();
# console.log = (log) ->
#   iframe = document.createElement("IFRAME");
#   iframe.setAttribute("src", "ios-log:#iOS#" + log);
#   document.documentElement.appendChild(iframe);
#   iframe.parentNode.removeChild(iframe);
#   iframe = null;    

# console.debug = console.log;
# console.info = console.log;
# console.warn = console.log;
# console.error = console.log;

USE_DUMMY_DATA = true

DUMMY_LOCATION =
  zip:    "94115"
  state:  "CA"
  city:   "San Francisco"
  geo_point: new Parse.GeoPoint 37.7642064, -122.4654489

window.pizzabuttonapp =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  State: {}
  Config: 
    delivery_radius: 2
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

    FastClick.attach(document.body)
    
    routes = new pizzabuttonapp.Routers.AppRouter

    pizzabuttonapp.State.user = getUserForAppState()
    pizzabuttonapp.State.user.fetch_related()

    pizzabuttonapp.State.order = new pizzabuttonapp.Models.OrderModel
      customer: pizzabuttonapp.State.user
    getLocation (loc) =>
      @State.location = loc
      getRestaurants (restaurants) =>
        if restaurants.length > 0
          @State.restaurants = restaurants
          @State.order.set_restaurant restaurants.at 0

    getConfig 'panic_button_enabled', (error, panic) ->
      pizzabuttonapp.State.panic = (panic=='true' or !!error)

    Backbone.history.start()

window.rotateOrder = ->
  attributes = pizzabuttonapp.State.order.attributes

  # Clean "ordered" state
  clean = ['error', 'charge_refunded_at', 'refund_error', 'stripe_chargeid', 'successfully_placed', 'total_charge']
  _(clean).each (key) -> delete attributes[key]

  # Special treatment for related models
  restaurant = pizzabuttonapp.State.order.get_restaurant()
  attributes['customer'] = pizzabuttonapp.State.user
  attributes['address']  = pizzabuttonapp.State.order.get_delivery_address()

  pizzabuttonapp.State.order = new pizzabuttonapp.Models.OrderModel attributes
  pizzabuttonapp.State.order.set_restaurant restaurant
  pizzabuttonapp.State.order

window.seedRestaurants = ->
  lm = new LocationManager

  pasquales = new pizzabuttonapp.Models.RestaurantModel
    menu:
      cheese:
        S: 7
        M: 11
        L: 13
        XL: 18
      pepperonni:
        S: 7
        M: 11
        L: 13
        XL: 18
    name: "Pasquale's Pizzeria"
    phone: "(415) 661-2140"
    address:
      street: '700 Irving St'
      city:   'San Francisco'
      state:  'CA'
      zip:    '94122'

  lm.geoCode pasquales.get('address'), (e, result) ->
    coordinates = new Parse.GeoPoint result.lat, result.lon

    pasquales.set 'coordinates', coordinates

    pasquales.save()


  escape = new pizzabuttonapp.Models.RestaurantModel
    menu:
      cheese:
        S: 8
        M: 12
        L: 14
        XL: 19
      pepperonni:
        S: 8
        M: 12
        L: 14
        XL: 19
    name: "Escape From New York!"
    phone: "(415) 668-5577"
    address:
      street: '1737 Haight St'
      city:   'San Francisco'
      state:  'CA'
      zip:    '94117'

  lm.geoCode escape.get('address'), (e, result) ->
    coordinates = new Parse.GeoPoint result.lat, result.lon

    escape.set 'coordinates', coordinates

    escape.save()

window.getConfig = (config_name, cb) ->
  configError = (object, error) ->
    console.error("COULDN'T RETRIEVE CONFIG VAR: "+config_name, error)
    cb error.code

  query = new Parse.Query(pizzabuttonapp.Models.ConfigModel)
  query.equalTo 'name', config_name
  query.find 
    success: (result) ->
      config = result[0]

      if config?
        cb null, config.get('value')
      else
        cb 
          code: "Config with that name not found."

    error: configError


locationCallbacks = []
window.locationUpdated = (lat, lng) ->
  window.latitude = lat
  window.longitude = lng
  for cb in locationCallbacks
    cb(lat,lng)
  locationCallbacks = []


createGeocodeCallback = (cb) ->
  (lat, lon) ->
    # TODO: Call to phone gap will give us lat/lon
    # lat = 37.7642064
    # lon = -122.4654489

    lm = new LocationManager
    lm.reverseGeoCode lat, lon, (err, result) ->
      # TODO: Better support for geo errors...
      throw err if err? 
      cb
        zip:    result.zip
        state:  result.state
        city:   result.city
        geo_point: new Parse.GeoPoint lat, lon

# Put phonegap location implementation here
getLocation = (cb) ->
  if USE_DUMMY_DATA
    cb DUMMY_LOCATION
    return
  if (window.latitude)
    createGeocodeCallback(cb)(window.latitude, longitude)
    return

  locationCallbacks.push createGeocodeCallback(cb)
 

getUserForAppState = -> 
  # Fetch related compenents to get started with user. 

  current_user = Parse.User.current()
  
  if !current_user?
    current_user = new Parse.User
      username: randomString 40
      password: randomString 40

    # TODO: Figure out some way to handle errors when creating these anonymous users.
    current_user.signUp
      error: ->
        console.error "FAILURE FETCHING USER", arguments

  current_user


window.clean_phone = (val) ->
  val.replace(/[^0-9]/g, '').replace(/^1/, '')

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
  location = pizzabuttonapp.State.location.geo_point
  radius   = pizzabuttonapp.Config.delivery_radius
  query = new Parse.Query(pizzabuttonapp.Models.RestaurantModel)
  query.withinMiles 'coordinates', location, radius
  restaurants = query.collection()
  restaurants.fetch
    success: cb


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

class window.LocationManager
  geoCode: (address, cb) ->
    add_str = "#{address.street},%20#{address.city},%20#{address.state}%20#{address.zip}"
    url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=#{add_str}"
    $.get(url).done (data) ->
      result = data.results[0]
      return cb "No Results" if !result?

      cb null,
        lat: result.geometry.location.lat
        lon: result.geometry.location.lng
        address: address

  reverseGeoCode: (lat, lng, cb) ->
    geocoder = new google.maps.Geocoder
    latLng = new google.maps.LatLng 1*lat, 1*lng

    geocoder.geocode
      latLng: latLng
      , (results, status) ->
        if status == google.maps.GeocoderStatus.OK
          result = results[0]

          # TODO: Handle no results

          findComponent = (key, returnname='long_name') ->
            winner = _.find result.address_components, (component) ->
              component.types.indexOf(key) != -1
            if winner? then winner[returnname] else null

          zip = findComponent 'postal_code'
          city = findComponent('sublocality') || findComponent('locality')
          state = findComponent 'administrative_area_level_1', 'short_name'

          cb null, 
            zip:    zip
            city:   city
            state:  state
        else
          # Return blank data, log error

      

$ ->
  'use strict'
  pizzabuttonapp.init();
