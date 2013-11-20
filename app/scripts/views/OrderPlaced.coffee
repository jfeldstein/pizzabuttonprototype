'use strict';

class pizzabuttonapp.Views.OrderPlacedView extends pizzabuttonapp.Views.BaseView

    events: 
      'click .js-new-order': 'new_order'

    template_data: ->
      @model.summary()

    initialize: ->
      @template = switch
        when @model.is_successfully_placed()  then JST['app/scripts/templates/OrderPlaced.ejs']
        when @model.is_credit_card_declined() then JST['app/scripts/templates/OrderFailCCDecline.ejs']
        else JST['app/scripts/templates/OrderFailOther.ejs']

    new_order: => 
      @options.order_again()
