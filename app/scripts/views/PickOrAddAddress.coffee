'use strict';

class pizzabuttonapp.Views.PickOrAddAddressView extends Backbone.View

    template: JST['app/scripts/templates/PickOrAddAddress.ejs']

    events: 
      'click .js-use-new-address': 'use_new_address'

    template_data: ->
      @new_address = new pizzabuttonapp.Models.AddressModel
        city: pizzabuttonapp.State.location.city
        state: pizzabuttonapp.State.location.state
        zip: pizzabuttonapp.State.location.zip

      existing_addresses: pizzabuttonapp.State.user.get_addresses().toJSON()
      new_address: @new_address.toJSON()

    render: ->
      @$el.html @template @template_data()
      pizzabuttonapp.Views.ViewPusher.render @el
      @delegateEvents()

    use_new_address: ->
      street = @$('[name="new_address[street]"]').val()

      return @show_street_error() if street == ''

      @new_address.set 'street', street
      
      pizzabuttonapp.State.user.add_address @new_address
      pizzabuttonapp.State.order.set_delivery_address @new_address

      @options.next_step()