'use strict';

class pizzabuttonapp.Views.AddCreditCardView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/AddCreditCard.ejs']
    active_view: "payment"

    events: 
      'click .js-save-card':          'save_card'
      'click .js-use-existing-card':  'use_existing_card'

    initialize: ->
      @new_credit_card = new pizzabuttonapp.Models.CreditCardModel

    template_data: ->
      existing_card:    pizzabuttonapp.State.user.get_primary_cc().toJSON() if pizzabuttonapp.State.user.has_primary_cc()
      new_credit_card:  @new_credit_card.toJSON()
      error:            @error if @error?

    render: ->
      super

      # Add cc field superpowers
      @$('[name="new_credit_card[number]"]').payment('formatCardNumber')
      @$('[name="new_credit_card[cvc]"]').payment('formatCardCVC')

    use_existing_card: ->
      @use_card pizzabuttonapp.State.user.get_primary_cc()

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
          @new_credit_card.save 
            token:      response.id
            last_four:  response.card.last4
            exp_month:  response.card.exp_month
            exp_year:   response.card.exp_year
            ,
              success: => @use_card(@new_credit_card)
              error: @card_save_failed

    card_save_failed: (card, e) =>
      @error = e.message
      @$('.js-save-card').attr('DISABLED', false).text("Try Again")
      @render()
    
    use_card: (card) ->
      # Attach card to user and order      
      pizzabuttonapp.State.user.set_primary_cc card
      pizzabuttonapp.State.order.set_billing_cc card

      # Go to next step
      @options.next_step()