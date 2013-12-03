'use strict';

class pizzabuttonapp.Routers.AppRouter extends Backbone.Router
  routes:
    'loading':         'loading'
    'orders/new':      'new_order'
    'additional_pizza':'additional_pizza'
    'wait_for_panic':  'wait_for_panic'
    'sessions/new':    'new_session'
    'wait_for_loc':    'wait_for_location'
    'wait_for_restaurants': 'wait_for_restaurants'
    'not_available':   'not_available'
    'ensure_address':  'ensure_address'
    'addresses/new':   'new_address'
    'ensure_cc':       'ensure_cc'
    'credit_cards/new':'new_credit_card'
    'orders/confirm':  'confirm_order'
    'orders/change_restaurant': 'change_restaurant'
    'orders/:id':      'show_order'
    '*path':           'loading'

  loading: ->
    new ensureAndWaitFor
      continue: => 
        @navigate 'orders/new', 
          trigger: true
      continue_when: -> 
        !pizzabuttonapp.State.user.id? || pizzabuttonapp.State.user.orders_are_fetched
      give_up: => 
        @navigate 'not_available',
          trigger: true 
      message: "The Pizza Button is loading..."

  new_order: ->
    pizzapicker = new pizzabuttonapp.Views.PizzaPickerView 
      model: pizzabuttonapp.State.order
      next_step: =>
        @navigate 'wait_for_panic', 
          trigger: true
      show_previous: => 
        previous_order = pizzabuttonapp.State.user.get_previous_order()
        pizzabuttonapp.State.order = previous_order
        pizzabuttonapp.State.order.fetch_related().then => 
          @navigate "orders/#{previous_order.id}",
            trigger: true
      confirm_same: =>
        previous_order = pizzabuttonapp.State.user.get_previous_order()
        previous_order.fetch_related().then =>
          rotateOrder previous_order
          @navigate 'orders/confirm',
            trigger: true
    pizzapicker.render()

  additional_pizza: ->
    pizzapicker = new pizzabuttonapp.Views.PizzaPickerView 
      model: pizzabuttonapp.State.order
      next_step: =>
        @navigate 'orders/confirm', 
          trigger: true
    pizzapicker.render()

  wait_for_panic: ->
    new ensureAndWaitFor
      continue: => 
        if pizzabuttonapp.State.panic
          @navigate 'not_available',
            trigger: true
        else 
          @navigate 'wait_for_loc', 
            trigger: true
      continue_when: -> 
        pizzabuttonapp.State.panic?
      give_up: => 
        @navigate 'not_available',
          trigger: true 
      message: "Checking for availability..."

  wait_for_location: -> 
    new ensureAndWaitFor
      continue: =>
        @navigate "wait_for_restaurants", 
          trigger: true
      continue_when: -> 
        pizzabuttonapp.State.location? 
      give_up: => 
        @navigate 'not_available',
          trigger: true 
      message: "Waiting for location..."

  wait_for_restaurants: ->
    process_restaurants = =>
      # Populated value for restaurants means we're within range... 
      if pizzabuttonapp.State.restaurants? 
        @navigate 'addresses/new',
          trigger: true
      else
        @navigate 'not_available',
          trigger: true

    new ensureAndWaitFor
      continue:       process_restaurants
      continue_when:  -> pizzabuttonapp.State.restaurants? 
      give_up:        => 
        @navigate 'not_available',
          trigger: true 
      message:        "Looking for pizza parlours..."

  ensure_cc: -> 
    if pizzabuttonapp.State.user? and pizzabuttonapp.State.user.has_primary_cc()
      # Apply the existing cc to this order
      default_cc = pizzabuttonapp.State.user.get_primary_cc()
      pizzabuttonapp.State.order.set_billing_cc default_cc

      # Continue to summary / confirmation
      @navigate 'orders/confirm', 
        trigger: true
    else
      @navigate 'credit_cards/new',
        trigger: true

  new_session: ->
    #

  not_available: ->
    not_available = new pizzabuttonapp.Views.NotAvailableView
    not_available.render()

  change_restaurant: =>
    change_restaurant = new pizzabuttonapp.Views.ChangeRestaurantView
      model: pizzabuttonapp.State.order
      return_to_order: =>
        @navigate 'orders/confirm',
          trigger: true
    change_restaurant.render()

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
    confirm_order = new pizzabuttonapp.Views.ConfirmOrderView
      model: pizzabuttonapp.State.order
      select_additional: => 
        @navigate 'additional_pizza',
          trigger: true
      next_step: =>
        @submit_order()
      change_restaurant: =>
        @navigate 'orders/change_restaurant',
          trigger: true
      change_address: =>
        @navigate 'addresses/new',
          trigger: true
    confirm_order.render()

  show_order: (id) ->
    order_ready = $.Deferred (defer) ->
      if pizzabuttonapp.State.order.id == id
        defer.resolve()
      else 
        pizzabuttonapp.State.order = new pizzabuttonapp.Models.OrderModel 
          objectId: id

        pizzabuttonapp.State.order.fetch
          success: defer.resolve
          error: defer.reject


    $.when(order_ready).then =>
      order_placed = new pizzabuttonapp.Views.OrderPlacedView
        model: pizzabuttonapp.State.order
        resubmit_order: =>
          rotateOrder()
          @submit_order()
        change_card: => 
          rotateOrder()
          @navigate 'credit_cards/new',
            trigger: true
        new_order: => 
          # Reset the order 
          pizzabuttonapp.State.order = new pizzabuttonapp.Models.OrderModel
            customer: pizzabuttonapp.State.user
            restaurant: pizzabuttonapp.State.restaurants.at(0)

          # Go back to the menu
          @navigate 'orders/new',
            trigger: true
            
      order_placed.render()

  submit_order: ->
    pizzabuttonapp.State.order.submit
      success: =>
        @navigate "orders/#{pizzabuttonapp.State.order.id}",
          trigger: true


  