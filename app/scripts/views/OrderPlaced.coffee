'use strict';

class pizzabuttonapp.Views.OrderPlacedView extends pizzabuttonapp.Views.BaseView

    events: 
      'click .js-new-order':    'new_order'
      'click .js-resubmit':     'resubmit_order'
      'click .js-change-card':  'change_card'

    template_data: ->
      @model.summary()

    initialize: ->
      @template = switch
        when @model.is_successfully_placed()  then JST['app/scripts/templates/OrderPlaced.ejs']
        when @model.is_credit_card_declined() then JST['app/scripts/templates/OrderFailCCDecline.ejs']
        else JST['app/scripts/templates/OrderFailOther.ejs']

    new_order: => 
      @options.new_order()

    resubmit_order: => 
      @$('.js-header').text("Re-Running Your Order...")
      @$('.js-resubmit').attr('DISABLED', true).text("Trying again...")
      @options.resubmit_order()

    change_card: => 
      @options.change_card()