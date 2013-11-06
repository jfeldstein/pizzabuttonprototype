'use strict';

class pizzabuttonapp.Views.AddCreditCardView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/AddCreditCard.ejs']

    events: 
      'click .js-use-new-credit-card': 'use_new_credit_card'

    template_data: ->
      @new_credit_card = new pizzabuttonapp.Models.CreditCardModel

      new_credit_card: @new_credit_card.toJSON()

    use_new_credit_card: ->
      # Get all field values
      fields = ['number', 'name', 'exp_month', 'exp_year', 'zip']
      values = {}

      _.each fields, (field) =>
        values[field] = @$('[name="new_credit_card['+field+']"]').val()

      # Validate
      # TODO: Validate the card's values ...

      # Build new card
      @new_credit_card.set values

      # Attach card to user and order      
      pizzabuttonapp.State.user.set_primary_cc @new_credit_card
      pizzabuttonapp.State.order.set_billing_cc @new_credit_card

      # Go to next step
      @options.next_step()