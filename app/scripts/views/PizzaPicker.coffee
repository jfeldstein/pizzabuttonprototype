'use strict';

class pizzabuttonapp.Views.PizzaPickerView extends Backbone.View

  template: JST['app/scripts/templates/PizzaPicker.ejs']

  events: 
    'click .js-add-pizza':    'add_pizza'
    'click .js-remove-pizza': 'remove_pizza'
    'change .js-size':        'update_pizzas'
    'click .js-continue':     'finish'

  add_pizza: (e) => 
    type = $(e.target).parents('[data-pizza-type]').data('pizza-type')
    @model.add_pizza(type)
    @updateUI()

  remove_pizza: (e) => 
    type = $(e.target).parents('[data-pizza-type]').data('pizza-type')
    @model.remove_pizza(type)
    @updateUI()

  template_data: ->
    # Rolls up individual pizzas into totals
    order_summary = @model.summary()

    pizza_selection = _.map pizzabuttonapp.Config.pizza_types, (type) ->
      # Does the order already include pizzas of the given type? 
      order_of_this_type = order_summary.pizzas[type]

      # If not found, start with these defaults
      order_of_this_type ||= 
        size: pizzabuttonapp.Config.pizza_sizes[0].code
        quantity: 0

      # Apply in-order quantities and sizes to the list of types of pizzas
      _.extend type, 
        size:     order_of_this_type.size
        quantity: order_of_this_type.quantity

    # Return this hash:
    pizzas: pizza_selection
    pizza_sizes: pizzabuttonapp.Config.pizza_sizes

  render: =>
    @$el.html @template @template_data()
    pizzabuttonapp.Views.ViewPusher.render @el
    @delegateEvents()
    @updateUI()

  updateUI: =>
    pizzas = @model.summary().pizzas

    @$('[data-pizza-type]').each (i, el) =>
      $el = $(el)
      type = $el.data('pizza-type')

      type_quantity = if pizzas[type]? then pizzas[type].quantity else 0
      type_size     = if pizzas[type]? then pizzas[type].size else pizzabuttonapp.Config.pizza_sizes[0].code

      $el.find('.js-quantity').text type_quantity
      $el.find('.js-size').val type_size

  update_pizzas: (e) => 
    @order.clear_pizzas()

    _.each data_from_view(), (pizza_type) =>
      for i in [0...pizza_type['quantity']]
        @order.add_pizza
          type: pizza_type['type']
          size: pizza_type['size']

  finish: => 
    @options.next_step()

  