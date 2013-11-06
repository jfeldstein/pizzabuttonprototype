'use strict';

class pizzabuttonapp.Models.CreditCardModel extends Backbone.Model
  toJSON: ->
    attrs = super

    _.extend
      last_four: @get('number').substr(-4)
      ,
      attrs
