'use strict';

class pizzabuttonapp.Routers.AppRouter extends Backbone.Router
  routes:
    'orders/new':      'new_order'
    'sessions/new':    'new_session'
    'wait_for_loc':    'wait_for_location'
    'wait_for_restaurants': 'wait_for_restaurants'
    'no_restaurants':  'out_of_area'
    'addresses/new':   'new_address'
    'credit_cards/new':'new_credit_card'
    'orders/confirm':  'confirm_order'
    'orders/:id':      'show_order'

  new_order: ->
    @order = new pizzabuttonapp.Models.OrderModel
    pizzapicker = new pizzabuttonapp.Views.PizzaPickerView 
      model: @order
      next_step: =>
        @navigate 'wait_for_loc', 
          trigger: true
    pizzapicker.render()

  wait_for_location: -> 
    seconds_to_wait  = 3
    poll_interval_ms = 100
    poll_counter     = 0

    poll_for_location = =>
      if pizzabuttonapp.State.location? 
        @navigate "wait_for_restaurants", 
          trigger: true
      else if poll_counter * poll_interval_ms / 1000 < seconds_to_wait
        poll_counter++
        setTimeout poll_for_location, poll_interval_ms
      else
        # Give up
        @out_of_area()

    if pizzabuttonapp.State.location? 
      @navigate "wait_for_restaurants", 
          trigger: true
    else
      waiting_view = new pizzabuttonapp.Views.WaitingView
        message: "Waiting for location..."
      waiting_view.render()
      poll_for_location()

  wait_for_restaurants: ->
    console.log "Waiting for restaurants now"

  new_session: ->
    #

  out_of_area: ->
    console.log "NO LOCATION"

  new_address: ->
    console.log("Check and get address", @order)

  new_credit_card: ->
    #

  confirm_order: ->
    #

  show_order: ->
    #

  