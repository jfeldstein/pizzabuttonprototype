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

    # Hack, if the order is created with an app-domain RestaurantModel object, put it where the get_restaurant hack expects it to be. 
    @restaurant = @get('restaurant') if @get('restaurant') instanceof pizzabuttonapp.Models.RestaurantModel

  summary: ->
    pizzas:       @get('pizzas')
    restaurant:   @get_restaurant().toJSON()    if @has('restaurant')
    selected_tip: @get('selected_tip')
    pizza_total:  @get_pizza_total()            if @has('restaurant')
    billing_cc:   @get_billing_cc().toJSON()    if @has('billing_cc')
    grand_total:  @get_grand_total()            if @has('restaurant')
    delivery_address: @get_delivery_address().toJSON() if @has('delivery_address')
    customer:     @get_customer().toJSON()      if @has('customer')

  get_customer: ->
    @get('customer')

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
    @set_phone_number address.get_phone_number()
    @set 'delivery_address', address
      
  set_phone_number: (number) ->
    @set 'phone_number', clean_phone(number)

  get_phone_number: ->
    @get 'phone_number'

  get_delivery_address: ->
    @get 'delivery_address'

  get_billing_cc: ->
    @get 'billing_cc'

  set_billing_cc: (credit_card) ->
    @set 'billing_cc', credit_card

  set_restaurant: (restaurant) ->
    @restaurant = restaurant
    @set 'restaurant', restaurant

  set_tip: (new_tip) ->
    @set 'selected_tip', new_tip

  get_restaurant: ->
    return null unless @has('restaurant')

    # Hack, because fetching orders' related objects populates the order with native Parse objects, not our classes.
    @restaurant ||= new pizzabuttonapp.Models.RestaurantModel 
      objectId: @get('restaurant').id if @get('restaurant')

  get_pizzas: ->
    @get('pizzas')

  get_service_fee: ->
    pizzabuttonapp.Config.service_fee

  get_tip: ->
    @get('selected_tip')

  get_total_charge: ->
    @get_pizza_total() + @get_service_fee() + @get_tip()

  submit: (options) ->
    @set
      total_charge: @get_total_charge()

    @save 
      success: options.success
      error: ->
        console.log "Failure saving order", arguments

  is_successfully_placed: -> 
    !!@get('successfully_placed')

  is_credit_card_declined: ->
    @get('error') == 'CHARGE_FAILED'


