'use strict';

class pizzabuttonapp.Views.OrderPlacedView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/OrderPlaced.ejs']

    events: 
      'click .js-new-order': 'new_order'

    template_data: ->
      restaurant: @model.get('restaurant')

    new_order: => 
      @options.order_again()