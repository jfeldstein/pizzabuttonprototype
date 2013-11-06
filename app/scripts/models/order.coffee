'use strict';

class pizzabuttonapp.Models.OrderModel extends Backbone.Model
  defaults: 
    pizzas: {}

  initialize: ->
    # Init pizzas
    pizzas = {}
    _.each pizzabuttonapp.Config.pizza_types, (ptype) =>
      pizzas[ptype.type] = 
        size: pizzabuttonapp.Config.pizza_sizes[0].code
        quantity: 0
    @set 'pizzas', pizzas

  summary: ->
    pizzas: @get('pizzas')

  add_pizza: (type) ->
    pizzas = @get('pizzas')

    pizzas[type].quantity += 1

    @set 'pizzas', pizzas

  remove_pizza: (type) ->
    pizzas = @get('pizzas')

    if pizzas[type].quantity > 0
      pizzas[type].quantity -= 1

    @set 'pizzas', pizzas

  resize_pizza: (type, new_size) ->
    pizzas = @get('pizzas')

    pizzas[type].size = new_size

    @set 'pizzas', pizzas

  existing_size_for_type: (type) => 
    return @get('pizzas')[type].size 

  set_delivery_address: (address) ->
    @set 'delivery_address', address

  set_billing_cc: (credit_card) ->
    @set 'billing_cc', credit_card



