'use strict';

class pizzabuttonapp.Views.ConfirmOrderView extends Backbone.View

    template: JST['app/scripts/templates/ConfirmOrder.ejs']

    events: 
      'click .js-confirm-order': 'confirm_order'
      'click .js-change-restaurant': 'select_new_restaunt'
      'change .js-restaurant-selector': 'update_restaurant'

    template_data: ->
      order: @model.toJSON()

    render: ->
      @$el.html @template @template_data()
      pizzabuttonapp.Views.ViewPusher.render @el
      @delegateEvents()

    confirm_order: ->
      @options.next_step()

    select_new_restaunt: ->
      # TODO: Let the user change the restaurant to deliver this order
      # Show picker for new restaurant

    update_restaurant: ->
      # TODO: Implement updating the restaurant selection
      # Update model
      # Slide new restaurant into view

