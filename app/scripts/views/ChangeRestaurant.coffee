'use strict';

class pizzabuttonapp.Views.ChangeRestaurantView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/ChangeRestaurant.ejs']
    active_view: "payment"

    template_data: ->
      order_pizzas = @model.summary().pizzas

      restaurants = pizzabuttonapp.State.restaurants.map (rest) =>
        _.extend rest.toJSON(), 
          new_total: @model.get_pizza_total(rest)

      restaurants: restaurants
      current_id: pizzabuttonapp.State.order.get_restaurant().id

    events:
      'click .restaurant': 'update_restaurant'

    update_restaurant: (e) =>
      rest_id = @$(e.currentTarget).data('restaurant-id')

      rest = pizzabuttonapp.State.restaurants.find (this_rest) ->
        this_rest.id == rest_id

      @model.set_restaurant rest

      @options.return_to_order()