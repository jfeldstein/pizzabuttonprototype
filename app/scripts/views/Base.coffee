'use strict';

class pizzabuttonapp.Views.BaseView extends Backbone.View
    
    # Gets overwritten by sub classes
    template_data: ->
      {}

    # Adds global stuff to all template() calls
    _template_data: ->
      _.defaults @template_data(),

        # Mix in a money helper, for formatting whole dollars 
        # as $X while dollars with cents get $X.XX
        money: (amount) ->
          accounting.formatMoney amount, 
            precision: if amount % 1 != 0 then 2 else 0


    render: ->
      @$el.html @template @_template_data()
      pizzabuttonapp.Views.ViewPusher.render @el
      @delegateEvents()

