'use strict';

class pizzabuttonapp.Models.OrderModel extends Parse.Object

  className: 'Order'

  defaults: 
    pizzas: {}
    selected_tip: 0

  initialize: ->
    # Init pizzas
    if not @has('pizzas')
      pizzas = {}
      _.each pizzabuttonapp.Config.pizza_types, (type) =>
        pizzas[type.id] = 
          size_id: pizzabuttonapp.Config.pizza_sizes[2].id
          quantity: 0
      @set 'pizzas', pizzas

    # Hack, if the order is created with an app-domain RestaurantModel object, put it where the get_restaurant hack expects it to be. 
    @restaurant = @get('restaurant') if @get('restaurant') instanceof pizzabuttonapp.Models.RestaurantModel


  # TODO: Trying to wrap fetch in something that adds extra steps to the end of the
  # deferred, but it's not working. We need it to fetch the order, then fetch related items, 
  # then call whatever success handler came in at the top, if there was one.
  fetch: (options) ->
    console.log("Fetching order")

    # Does not work when order is created by rotateOrder, and does not have an .id specified.
    (OrderModel.__super__.fetch.apply(this, [])).then => 
      @fetch_related().then ->
        options.success() if options.success?

  fetch_related: ->
    fetch_rest = $.Deferred (defer) =>
      @get_restaurant().fetch deferredHandlers(defer)

    fetch_addr = $.Deferred (defer) =>
      @get_delivery_address().fetch deferredHandlers(defer)

    fetch_cc = $.Deferred (defer) =>
      @get_billing_cc().fetch deferredHandlers(defer)

    $.when fetch_rest, fetch_addr, fetch_cc
    

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

  set_delivery_address: (address) ->
    @set_phone_number address.get_phone_number()
    @set 'delivery_address', address
      
  set_phone_number: (number) ->
    @set 'phone_number', clean_phone(number)

  get_phone_number: ->
    @get 'phone_number'

  get_delivery_address: ->
    if @get('delivery_address')? and !(@get('delivery_address') instanceof pizzabuttonapp.Models.AddressModel)
      # Convert address to AddressModel
      attrs    = @get('delivery_address').attributes
      attrs.objectId = @get('delivery_address').id
      @set 'delivery_address', new pizzabuttonapp.Models.AddressModel(attrs)

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
    if @get('restaurant')? and !(@get('restaurant') instanceof pizzabuttonapp.Models.RestaurantModel)
      # Convert restaurant to RestaurantModel
      attrs    = @get('restaurant').attributes
      attrs.objectId = @get('restaurant').id
      @set_restaurant new pizzabuttonapp.Models.RestaurantModel(attrs)

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


