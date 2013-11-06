'use strict';

class pizzabuttonapp.Views.WaitingView extends Backbone.View

    template: JST['app/scripts/templates/Waiting.ejs']

    template_data: -> 
      message: @options.message

    render: =>
      @$el.html @template @template_data()
      pizzabuttonapp.Views.ViewPusher.render @el
