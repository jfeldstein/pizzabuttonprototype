'use strict';

class pizzabuttonapp.Models.OrderModel extends Backbone.Model
  defaults: 
    pizzas: []

  summary: ->
    pizza_summary = {}

    _.each @get('pizzas'), (pizza) ->
      pizza_summary[pizza.type] ||=
        size: pizza.size
        quantity: 0

      pizza_summary[pizza.type].quantity += 1

    pizzas: pizza_summary

  add_pizza: (type) ->
    pizzas = @get('pizzas')

    pizzas.push 
      size: @existing_size_for_type(type)
      type: type

    @set 'pizzas', pizzas

  existing_size_for_type: (type) => 
    existing_pizza = _.find @get('pizzas'), (pizza) ->
      pizza.type == type

    if existing_pizza? then existing_pizza.size else pizzabuttonapp.Config.pizza_sizes[0].code



