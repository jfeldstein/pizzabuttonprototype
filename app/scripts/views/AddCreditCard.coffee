'use strict';

class pizzabuttonapp.Views.AddCreditCardView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/AddCreditCard.ejs']

    events: 
      'click .js-save-card': 'save_card'

    initialize: ->
      @new_credit_card = new pizzabuttonapp.Models.CreditCardModel

    template_data: ->
      new_credit_card:  @new_credit_card.toJSON()
      error:            @error if @error?

    save_card: ->
      @$('.js-save-card').attr('DISABLED', 'DISABLED').text("Saving Your Card...")

      # Get all field values
      fields = ['number', 'exp_month', 'exp_year', 'cvc']
      values = {}
      _.each fields, (field) =>
        values[field] = @$('[name="new_credit_card['+field+']"]').val()

      # Build new card
      Stripe.card.createToken values, (status, response) =>
        if response.error
          @error = response.error.message
          @render()
        else
          @new_credit_card.set 
            token:      response.id
            last_four:  response.card.last4
            exp_month:  response.card.exp_month
            exp_year:   response.card.exp_year
          @use_new_credit_card()
    
    use_new_credit_card: ->
      # Attach card to user and order      
      pizzabuttonapp.State.user.set_primary_cc @new_credit_card
      pizzabuttonapp.State.order.set_billing_cc @new_credit_card

      # Go to next step
      @options.next_step()