'use strict';

class pizzabuttonapp.Views.OrderPlacedView extends pizzabuttonapp.Views.BaseView

    # template: ... (set in init)
    active_view: "payment"

    events: 
      'click .js-new-order':    'new_order'
      'click .js-resubmit':     'resubmit_order'
      'click .js-change-card':  'change_card'
      'click .js-brag':         'brag'

    template_data: ->
      summary = @model.summary()

      # Break out which pizzas to list
      pizza_types_in_order = []
      _.each pizzabuttonapp.Config.pizza_types, (type) =>
        if summary.pizzas[type.id]? and summary.pizzas[type.id].quantity > 0
          size = _.find pizzabuttonapp.Config.pizza_sizes, (this_size) ->
            this_size.id == summary.pizzas[type.id].size_id

          qty = summary.pizzas[type.id].quantity
          unit_price = summary.restaurant.menu[type.id][size.id]

          pizza_types_in_order.push 
            type:      type
            quantity:  qty
            size_id:   size.id
            subtotal:  qty * unit_price

      tip_class = if (summary.selected_tip >= summary.total_pizzas*2) then 'confirm' else ''

      pizza_sizes:          pizzabuttonapp.Config.pizza_sizes
      pizza_types_in_order: pizza_types_in_order
      restaurant:           summary.restaurant
      delivery_address:     summary.delivery_address
      customer:             summary.customer
      selected_tip:         summary.selected_tip
      grand_total:          summary.grand_total
      cc_last_four:         summary.billing_cc.last_four
      sub_total:            summary.pizza_total + pizzabuttonapp.Config.service_fee
      service_fee:          summary.service_fee
      tip_class:            tip_class

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

    brag: =>
      share_url = 'http://twitter.com/intent/tweet?text=I%20just%20ordered%20a%20pizza%20using%20@ThePizzaButton.%20The%20future%20is%20here&url=thepizzabutton.com'

      window.location = share_url
