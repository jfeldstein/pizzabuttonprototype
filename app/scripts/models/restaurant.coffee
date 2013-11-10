'use strict';

class pizzabuttonapp.Models.RestaurantModel extends Parse.Object

    className: 'Restaurant'

    get_menu: ->
      @get('menu')

    get_cost_of_pizzas: (pizzas) =>
      menu = @get_menu()
      unit_cost = menu[pizzas.pizza_id][pizzas.size_id]

      unit_cost * pizzas.quantity
