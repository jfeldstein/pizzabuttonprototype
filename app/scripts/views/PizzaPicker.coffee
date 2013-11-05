'use strict';

class pizzabuttonapp.Views.PizzaPickerView extends Backbone.View

  template: JST['app/scripts/templates/PizzaPicker.ejs']

  events: 
    'click .js-add-pizza':    'add_pizza'
    'click .js-remove-pizza': 'remove_pizza'
    'change .js-pizza-size':  'update_sizes'
    'click .js-continue':     'finish'

  render: ->
    @$el.html @template()
    pizzabuttonapp.Views.ViewPusher.render @el

  add_pizza: (e) => 
    #

  remove_pizza: (e) => 
    #

  update_sizes: (e) => 
    #

  finish: => 
    @options.next_step()

  