'use strict';

class pizzabuttonapp.Models.OrderModel extends Backbone.Model
  defaults: 
    pizzas: {}

  summary: ->
    pizzas: @get('pizzas')

  add_pizza: (type) ->
    pizzas = @get('pizzas')

    pizzas[type] ||= 
      size: pizzabuttonapp.Config.pizza_sizes[0].code
      quantity: 0

    pizzas[type].quantity += 1

    @set 'pizzas', pizzas

  existing_size_for_type: (type) => 
    if @get('pizzas')[type]? 
      return @get('pizzas')[type].size 
    else 
      pizzabuttonapp.Config.pizza_sizes[0].code



