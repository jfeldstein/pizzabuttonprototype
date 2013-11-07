'use strict';

# TODO: Use requireJS to make sure that AddressCollection is loaded first. Currently, depends on order in index.html

_.extend Parse.User.prototype, 

  fetch_related: -> 
    @get_addresses().fetch()

  has_primary_address: ->
    @get_addresses().length >= 1

  get_primary_address: ->
    # "Primary" address is currently just the first address
    @get_addresses().at 0

  get_addresses: ->
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

