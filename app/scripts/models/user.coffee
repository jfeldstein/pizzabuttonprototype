'use strict';

# TODO: Use requireJS to make sure that AddressCollection is loaded first. Currently, depends on order in index.html

class pizzabuttonapp.Models.UserModel extends Backbone.Model
  defaults: 
    addresses: new pizzabuttonapp.Collections.AddressCollection

  has_primary_address: ->
    @get_addresses().length >= 1

  get_primary_address: ->
    # "Primary" address is currently just the first address
    @get('addresses').at 0

  get_addresses: ->
    @get('addresses')

  add_address: (new_address) ->
    @get('addresses').add new_address

  has_primary_cc: ->
    @has('credit_card')

  get_primary_cc: ->
    @get('credit_card')

  set_primary_cc: (new_card) ->
    @set 'credit_card', new_card

