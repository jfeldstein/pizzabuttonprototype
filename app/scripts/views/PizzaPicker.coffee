'use strict';

class pizzabuttonapp.Views.PizzaPickerView extends pizzabuttonapp.Views.BaseView

  template: JST['app/scripts/templates/PizzaPicker.ejs']
  active_view: "order"

  initialize: ->
    @listenTo @model.get('customer'), 'change:orders', @render

  events: 
    'click .js-add-pizza':        'add_pizza'
    'click .js-show-previous':    'show_previous'
    'click .js-confirm-same':     'confirm_same'

  template_data: ->
    # Rolls up individual pizzas into totals
    order_summary = @model.summary()
    has_selected_pizza = false

    pizza_selection = _.map pizzabuttonapp.Config.pizza_types, (type) ->
      # Does the order already include pizzas of the given type? 
      order_of_this_type = order_summary.pizzas[type.id]

      # If not found, start with these defaults
      order_of_this_type ||= 
        size_id: pizzabuttonapp.Config.pizza_sizes[0].id
        quantity: 0

      # Boolean for "has the user picked something"
      has_selected_pizza = true if order_of_this_type.quantity > 0

      # Apply in-order quantities and sizes to the list of types of pizzas
      _.extend type, 
        size_id:  order_of_this_type.size_id
        quantity: order_of_this_type.quantity
        type_id: type.id

    # Is there a previously placed order?
    previous_order = pizzabuttonapp.State.user.get_previous_order()
    if previous_order?
      previous_order = previous_order.toJSON()
      
      # Was it placed recently?
      minutes_ago = ((new Date()) - new Date(previous_order.createdAt)) / 60000
      in_progress_order = previous_order if minutes_ago < 90

    # Return this hash:
    in_progress_order:  in_progress_order if in_progress_order?
    previous_order:     previous_order if previous_order?
    pizzas:             pizza_selection
    pizza_sizes:        pizzabuttonapp.Config.pizza_sizes
    has_selected_pizza: has_selected_pizza

  show_previous: ->
    @options.show_previous()

  confirm_same: ->
    @options.confirm_same()

  add_pizza: (e) => 
    type_id = $(e.target).parents('[data-pizza-type-id]').data('pizza-type-id')
    @model.add_pizza(type_id)
    @options.next_step()

  