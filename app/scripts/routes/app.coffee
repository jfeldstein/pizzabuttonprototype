'use strict';

class pizzabuttonapp.Routers.AppRouter extends Backbone.Router
  routes:
    'orders/new':      'new_order'
    'sessions/new':    'new_session'
    'no_restaurants':  'out_of_area'
    'addresses/new':   'new_address'
    'credit_cards/new':'new_credit_card'
    'orders/confirm':  'confirm_order'
    'orders/:id':      'show_order'

  new_order: ->
    order = new pizzabuttonapp.Models.OrderModel
    pizzapicker = new pizzabuttonapp.Views.PizzaPickerView 
      model: order
      next_step: @new_address
    pizzapicker.render()

  new_session: ->
    #

  out_of_area: ->
    #

  new_address: ->
    console.log("Check and get address")

  new_credit_card: ->
    #

  confirm_order: ->
    #

  show_order: ->
    #

  