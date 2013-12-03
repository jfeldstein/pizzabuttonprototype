'use strict';

class pizzabuttonapp.Views.ConfirmOrderView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/ConfirmOrder.ejs']
    active_view: "payment"

    events: 
      'click .js-confirm-order':        'confirm_order'
      'click .js-change-restaurant':    'select_new_restaunt'
      'click .js-change-address':       'select_new_address'
      'click .js-tip-plus':             'plus_tip'
      'click .js-tip-minus':            'minus_tip'
      'change .js-size-id':             'resize_pizza'
      'click .js-add-pizza':            'add_pizza'
      'click .js-remove-pizza':         'remove_pizza'
      'click .js-select-additional':    'select_additional'
      'click .js-change-card':          'change_card'

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

    confirm_order: ->
      @$('.js-confirm-order').attr('DISABLED', 'DISABLED').text('Placing Order...')
      @options.next_step()

    resize_pizza: (e) => 
      type_id = $(e.target).parents('[data-pizza-type-id]').data('pizza-type-id')
      new_size_id = $(e.target).val()
      @model.resize_pizza(type_id, new_size_id)
      @render()

    add_pizza: (e) => 
      type_id = $(e.target).parents('[data-pizza-type-id]').data('pizza-type-id')
      @model.add_pizza(type_id)
      @render()

    remove_pizza: (e) => 
      type_id = $(e.target).parents('[data-pizza-type-id]').data('pizza-type-id')
      @model.remove_pizza(type_id)
      @render()

    select_additional: =>
      @options.select_additional()

    plus_tip: =>
      @model.set_tip @model.get_tip()+1
      @render()

    minus_tip: =>
      new_tip = @model.get_tip()-1
      new_tip = 0 if new_tip < 0
      @model.set_tip new_tip
      @render()

    select_new_restaunt: ->
      @options.change_restaurant()

    select_new_address: ->
      @options.change_address()

    change_card: => 
      @options.change_card()

