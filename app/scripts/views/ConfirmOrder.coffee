'use strict';

class pizzabuttonapp.Views.ConfirmOrderView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/ConfirmOrder.ejs']

    events: 
      'click .js-confirm-order':        'confirm_order'
      'click .js-change-restaurant':    'select_new_restaunt'
      'change .js-restaurant-selector': 'update_restaurant'
      'click [data-tip-amount]':        'set_tip'

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
            type_name: type.friendly_name
            quantity: qty
            size_name: size.friendly_name
            subtotal: qty * unit_price

      pizza_types_in_order: pizza_types_in_order
      restaurant:           summary.restaurant
      selected_tip:         summary.selected_tip
      grand_total:          summary.grand_total
      cc_last_four:         summary.billing_cc.last_four
      sub_total:            summary.pizza_total + pizzabuttonapp.Config.service_fee
      service_fee:          pizzabuttonapp.Config.service_fee

    confirm_order: ->
      @$('.js-confirm-order').attr('DISABLED', 'DISABLED').text('Placing Order...')
      @options.next_step()

    set_tip: (e) =>
      # Pull from view
      new_tip = $(e.target).data('tip-amount')
      
      # Update the order's data
      @model.set_tip new_tip

      # Update view
      @render()

    select_new_restaunt: ->
      @options.change_restaurant()

