'use strict';

class pizzabuttonapp.Models.OrderModel extends Parse.Object

  className: 'Order'

  defaults: 
    pizzas: {}
    selected_tip: 0

  initialize: ->
    # Init pizzas
    pizzas = {}
    _.each pizzabuttonapp.Config.pizza_types, (type) =>
      pizzas[type.id] = 
        size_id: pizzabuttonapp.Config.pizza_sizes[0].id
        quantity: 0
    @set 'pizzas', pizzas

  summary: ->
    pizzas:       @get('pizzas')
    restaurant:   @get('restaurant').toJSON()   if @has('restaurant')
    selected_tip: @get('selected_tip')
    pizza_total:  @get_pizza_total()            if @has('restaurant')
    billing_cc:   @get_billing_cc().toJSON()    if @has('billing_cc')
    grand_total:  @get_grand_total()            if @has('restaurant')

  get_grand_total: ->
    @get_pizza_total() + @get('selected_tip') + pizzabuttonapp.Config.service_fee

  get_pizza_total: (restaurant = @get_restaurant()) -> 
    add_cost_of_pizza = (memo, picked, pizza_id) =>
      memo + restaurant.get_cost_of_pizzas 
        pizza_id: pizza_id
        size_id:  picked.size_id
        quantity: picked.quantity

    _.reduce @get_pizzas(), add_cost_of_pizza, 0

  add_pizza: (type_id) ->
    pizzas = @get('pizzas')

    pizzas[type_id].quantity += 1

    @set 'pizzas', pizzas

  remove_pizza: (type_id) ->
    pizzas = @get('pizzas')

    if pizzas[type_id].quantity > 0
      pizzas[type_id].quantity -= 1

    @set 'pizzas', pizzas

  resize_pizza: (type, new_size_id) ->
    pizzas = @get('pizzas')

    pizzas[type].size_id = new_size_id

    @set 'pizzas', pizzas

  #existing_size_id_for_type_id: (type_id) => 
  #  return @get('pizzas')[type_id].size_id

  set_delivery_address: (address) ->
    @set 'delivery_address', address

  get_billing_cc: ->
    @get 'billing_cc'

  set_billing_cc: (credit_card) ->
    @set 'billing_cc', credit_card

  set_restaurant: (restaurant) ->
    @set 'restaurant', restaurant

  set_tip: (new_tip) ->
    @set 'selected_tip', new_tip

  get_restaurant: ->
    @get('restaurant')

  get_pizzas: ->
    @get('pizzas')

  get_service_fee: ->
    pizzabuttonapp.Config.service_fee

  get_tip: ->
    @get('tip')

  get_total_charge: ->
    @get_pizza_total() + @get_service_fee() + @get_tip()

  submit: (options) ->
    @set
      total_charge: @get_total_charge()

    @save 
      success: options.success
      error: ->
        console.log "Failure saving order", arguments


