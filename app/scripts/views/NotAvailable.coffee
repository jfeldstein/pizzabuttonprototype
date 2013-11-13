'use strict';

class pizzabuttonapp.Views.NotAvailableView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/NotAvailable.ejs']

    template_data: ->
      # TODO: Support for no supported restaurants, by googling for any nearby restaurant and passing off the phone number. 
      restaurant = pizzabuttonapp.State.restaurants.at(0) if pizzabuttonapp.State.restaurants?

      restaurant_name: restaurant.get('name') if restaurant?
      phone_to_dial:   restaurant.get('phone').replace(/[^0-9]+/g, '') if restaurant?

