'use strict';

class pizzabuttonapp.Models.CreditCardModel extends Parse.Object
  
  className: 'CreditCard'

  toJSON: ->
    attrs = super

    _.extend
      last_four: @get('number').substr(-4) if @has('number')
      ,
      attrs
