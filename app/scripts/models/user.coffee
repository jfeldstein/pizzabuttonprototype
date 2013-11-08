'use strict';

# TODO: Use requireJS to make sure that AddressCollection is loaded first. Currently, depends on order in index.html

_.extend Parse.User.prototype, 

  fetch_related: -> 
    @get_addresses().fetch()
    @get_primary_cc().fetch()
    @get_orders().fetch 
      success: =>
        @trigger 'change:orders'

  has_primary_address: ->
    @get_addresses().length >= 1

  get_primary_address: ->
    # "Primary" address is currently just the first address
    @get_addresses().at 0

  get_addresses: ->
    # Can't fetch addresses from Parse if user is not yet saved
    if !@id?
      return new pizzabuttonapp.Collections.AddressCollection

    if !@addresses?
      address_query = new Parse.Query(pizzabuttonapp.Models.AddressModel)
      address_query.equalTo('user', @)
      @addresses = address_query.collection()

    @addresses
    
  add_address: (new_address) ->
    # Persist the relation
    new_address.save
      user: @

    # Make accessible locally
    @get_addresses().add new_address

  get_orders: ->
    # Can't fetch orders from Parse if user is not yet saved
    if !@id?
      return new pizzabuttonapp.Collections.OrderCollection

    if !@orders?
      order_query = new Parse.Query(pizzabuttonapp.Models.OrderModel)
      order_query.equalTo('customer', @)
      @orders = order_query.collection()

    @orders

  get_in_progress_order: ->
    most_recent_order = @get_orders().at(0)

    return null unless most_recent_order?

    minutes_ago = ((new Date()) - most_recent_order.createdAt) / 60000

    if minutes_ago < 90 then most_recent_order else null

  has_primary_cc: ->
    @has('credit_card')

  get_primary_cc: ->
    @get('credit_card')

  set_primary_cc: (new_card) ->
    # Persist the relation and foreign object
    new_card.save 'user', @

    # Save again on the user to set locally, and also to make sure 
    # it's available from the user object on next load. 
    @save 'credit_card', new_card

