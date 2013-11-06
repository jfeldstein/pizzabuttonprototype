'use strict';

class pizzabuttonapp.Routers.AppRouter extends Backbone.Router
  routes:
    'orders/new':      'new_order'
    'sessions/new':    'new_session'
    'wait_for_loc':    'wait_for_location'
    'wait_for_restaurants': 'wait_for_restaurants'
    'no_restaurants':  'out_of_area'
    'ensure_address':  'ensure_address'
    'addresses/new':   'new_address'
    'ensure_cc':       'ensure_cc'
    'credit_cards/new':'new_credit_card'
    'orders/confirm':  'confirm_order'
    'orders/:id':      'show_order'

  new_order: ->
    pizzapicker = new pizzabuttonapp.Views.PizzaPickerView 
      model: pizzabuttonapp.State.order
      next_step: =>
        @navigate 'wait_for_loc', 
          trigger: true
    pizzapicker.render()

  wait_for_location: -> 
    new ensureAndWaitFor
      continue: =>
        @navigate "wait_for_restaurants", 
          trigger: true
      continue_when:  -> pizzabuttonapp.State.location? 
      give_up:        => @out_of_area() 
      message:        "Waiting for location..."

  wait_for_restaurants: ->
    process_restaurants = =>
      # Populated value for restaurants means we're within range... 
      if pizzabuttonapp.State.restaurants? 
        @navigate 'ensure_address',
          trigger: true
      else
        @navigate 'no_restaurants',
          trigger: true

    new ensureAndWaitFor
      continue:       process_restaurants
      continue_when:  -> pizzabuttonapp.State.restaurants? 
      give_up:        => @out_of_area() 
      message:        "Looking for pizza parlours..."

  ensure_address: ->
    if pizzabuttonapp.State.user? and pizzabuttonapp.State.user.get_primary_address()?
      # TODO: Are we near the address? If not, we still need a new one / user to pick.
      @navigate 'ensure_cc', 
        trigger: true
    else
      @navigate 'addresses/new',
        trigger: true

  ensure_cc: -> 
    if pizzabuttonapp.State.user? and pizzabuttonapp.State.user.has_primary_cc()
      @navigate 'orders/confirm', 
        trigger: true
    else
      @navigate 'credit_cards/new',
        trigger: true

  new_session: ->
    #

  out_of_area: ->
    console.log "NO LOCATION"

  new_address: =>
    pick_or_add_address = new pizzabuttonapp.Views.PickOrAddAddressView
      model: pizzabuttonapp.State.user
      next_step: =>
        @navigate 'ensure_cc',
          trigger: true
    pick_or_add_address.render()

  new_credit_card: ->
    add_credit_card = new pizzabuttonapp.Views.AddCreditCardView
      model: pizzabuttonapp.State.order
      next_step: => 
        @navigate 'orders/confirm',
          trigger: true
    add_credit_card.render()

  confirm_order: ->
    console.log("CONFIRM ORDER", pizzabuttonapp.State.order)

  show_order: ->
    #

  