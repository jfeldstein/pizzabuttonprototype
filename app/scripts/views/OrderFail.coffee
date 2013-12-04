'use strict';

class pizzabuttonapp.Views.OrderFailView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/OrderFailOther.ejs']
    active_view: "payment"

    events: 
      'click .js-resubmit': 'resubmit'

    template_data: ->
      @model.summary()

    resubmit: (e) =>
      @$(e.target).attr("disabled", true).text("Placing Order...")
      @options.resubmit()
