'use strict';

# TODO: Use requireJS to make sure that AddressCollection is loaded first. Currently, depends on order in index.html

_.extend Parse.User.prototype, 

  defaults: 
    phone_number: ''

  fetch_related: -> 
    @fetch
      success: =>
        @get_addresses().fetch()
        @get_primary_cc().fetch()

        # Can't fetch orders from Parse if user is not yet saved
        if @id?
          @get_orders().fetch 
            success: =>
              @orders_are_fetched = true
              @trigger 'change:orders' # TODO: Move loading data before render to app.coffee

  get_addresses: ->
    # Can't fetch addresses from Parse if user is not yet saved
    if !@id?
      return new pizzabuttonapp.Collections.AddressCollection

    if !@addresses?
      address_query = new Parse.Query(pizzabuttonapp.Models.AddressModel)
      address_query.equalTo('user', @)
      @addresses = address_query.collection()

    @addresses
    
  get_address_by_id: (id) ->
    @get_addresses().find (address) ->
      address.id == id

  add_address: (new_address) ->
    # Persist the relation
    new_address.save
      user: @

    # Set the default phone number if not already present:
    if @get_phone_number()==''
      @set_phone_number new_address.get_phone_number()

    # Make accessible locally
    @get_addresses().add new_address

  get_phone_number: ->
    @get 'phone_number'

  set_phone_number: (val) ->
    @set 'phone_number', clean_phone(val)

  get_orders: ->
    # Can't fetch orders from Parse if user is not yet saved
    if !@id?
      return new pizzabuttonapp.Collections.OrderCollection

    if !@orders?
      order_query = new Parse.Query(pizzabuttonapp.Models.OrderModel)
      order_query.equalTo('customer', @)
      order_query.descending('createdAt')
      @orders = new pizzabuttonapp.Collections.OrderCollection [],
        query: order_query

    @orders 

  get_previous_order: ->
    @get_orders().at(0)

  has_primary_cc: ->
    @has('credit_card')

  get_primary_cc: ->
    @get('credit_card') || new pizzabuttonapp.Models.CreditCardModel

  set_primary_cc: (new_card) ->
    # Persist the relation and foreign object
    new_card.save 'user', @

    # Save again on the user to set locally, and also to make sure 
    # it's available from the user object on next load. 
    @save 'credit_card', new_card

