'use strict';

class pizzabuttonapp.Views.WaitingView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/Waiting.ejs']

    template_data: -> 
      message: @options.message
