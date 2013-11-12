'use strict';

class pizzabuttonapp.Views.PickOrAddAddressView extends pizzabuttonapp.Views.BaseView

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

    use_new_address: ->
      street = @$('[name="new_address[street]"]').val()
      zip = @$('[name="new_address[zip]"]').val()

      return @show_street_error() if street=='' or zip==''

      @new_address.set 
        street: street
        zip: zip

      lm = new LocationManager
      lm.geoCode @new_address.toJSON(), (err, result) =>
        throw err if err?

        geo_point = new Parse.GeoPoint result.lat, result.lon
        @new_address.set 'geo_point', geo_point
      
        pizzabuttonapp.State.user.add_address @new_address
        pizzabuttonapp.State.order.set_delivery_address @new_address

        @options.next_step()
