'use strict';

class pizzabuttonapp.Models.AddressModel extends Parse.Object
  
    className: 'Address'

    set_phone_number: (number) ->
      @set 'phone_number', clean_phone(number)

    get_phone_number: ->
      @get 'phone_number'
