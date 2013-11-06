'use strict';

class pizzabuttonapp.Views.PizzaPickerView extends pizzabuttonapp.Views.BaseView

  template: JST['app/scripts/templates/PizzaPicker.ejs']

  events: 
    'click .js-add-pizza':    'add_pizza'
    'click .js-remove-pizza': 'remove_pizza'
    'change .js-size-id':        'resize_pizza'
    'click .js-continue':     'finish'

  add_pizza: (e) => 
    type_id = $(e.target).parents('[data-pizza-type-id]').data('pizza-type-id')
    @model.add_pizza(type_id)
    @updateUI()

  remove_pizza: (e) => 
    type_id = $(e.target).parents('[data-pizza-type-id]').data('pizza-type-id')
    @model.remove_pizza(type_id)
    @updateUI()

  resize_pizza: (e) => 
    type_id = $(e.target).parents('[data-pizza-type-id]').data('pizza-type-id')
    new_size_id = $(e.target).val()
    @model.resize_pizza(type_id, new_size_id)
    @updateUI()

  template_data: ->
    # Rolls up individual pizzas into totals
    order_summary = @model.summary()

    pizza_selection = _.map pizzabuttonapp.Config.pizza_types, (type) ->
      # Does the order already include pizzas of the given type? 
      order_of_this_type = order_summary.pizzas[type.id]

      # If not found, start with these defaults
      order_of_this_type ||= 
        size_id: pizzabuttonapp.Config.pizza_sizes[0].id
        quantity: 0

      # Apply in-order quantities and sizes to the list of types of pizzas
      _.extend type, 
        size_id:  order_of_this_type.size_id
        quantity: order_of_this_type.quantity
        type_id: type.id

    # Return this hash:
    pizzas: pizza_selection
    pizza_sizes: pizzabuttonapp.Config.pizza_sizes

  render: =>
    super
    @updateUI()

  updateUI: =>
    pizzas = @model.summary().pizzas

    @$('[data-pizza-type-id]').each (i, el) =>
      $el = $(el)
      type_id = $el.data('pizza-type-id')

      quantity = if pizzas[type_id]? then pizzas[type_id].quantity else 0
      size     = if pizzas[type_id]? then pizzas[type_id].size_id else pizzabuttonapp.Config.pizza_sizes[0].id

      $el.find('.js-quantity').text quantity
      $el.find('.js-size').val size

  finish: => 
    @options.next_step()

  