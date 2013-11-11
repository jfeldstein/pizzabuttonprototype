'use strict';

class pizzabuttonapp.Views.ChangeRestaurantView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/ChangeRestaurant.ejs']

    template_data: ->
      order_pizzas = @model.summary().pizzas

      restaurants = pizzabuttonapp.State.restaurants.map (rest) =>
        _.extend rest.toJSON(), 
          new_total: @model.get_pizza_total(rest)

      restaurants: restaurants
      current_id: pizzabuttonapp.State.order.get_restaurant().id

    events:
      'change [name="restaurant"]': 'update_restaurant'
      'click .js-cancel': 'cancel'

    update_restaurant: =>
      rest_id = @$('[name="restaurant"]:checked').val()

      rest = pizzabuttonapp.State.restaurants.find (this_rest) ->
        this_rest.id == rest_id

      @model.set 'restaurant', rest

      @options.return_to_order()

    cancel: ->
      @options.return_to_order()