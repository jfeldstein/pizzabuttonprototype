'use strict';

class pizzabuttonapp.Views.PickOrAddAddressView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/PickOrAddAddress.ejs']
    active_view: "address"

    events: 
      'keyup input':                    'validate'
      'click .js-use-new-address':      'use_new_address'
      'click .js-use-existing-address': 'use_existing_address'

    template_data: ->
      @new_address = new pizzabuttonapp.Models.AddressModel
        city: pizzabuttonapp.State.location.city
        state: pizzabuttonapp.State.location.state
        zip: pizzabuttonapp.State.location.zip
        phone_number: pizzabuttonapp.State.user.get_phone_number()

      existing_addresses: pizzabuttonapp.State.user.get_addresses().toJSON()
      new_address:        @new_address.toJSON()

    get_street_value: ->
      @$('[name="new_address[street]"]').val()

    get_zip_value: ->
      @$('[name="new_address[zip]"]').val()

    get_phone_value: ->
      clean_phone @$('[name="new_address[phone_number]"]').val()

    use_existing_address: (e) =>
      id = $(e.currentTarget).data('address-id')

      address = pizzabuttonapp.State.user.get_address_by_id id

      pizzabuttonapp.State.order.set_delivery_address address 

      @options.next_step()  

    validate: ->
      @$('.js-use-new-address').attr 'disabled', !@valid()

    use_new_address: ->
      @new_address.set 
        street: @get_street_value()
        zip:    @get_zip_value()
        phone_number: @get_phone_value()

      lm = new LocationManager
      lm.geoCode @new_address.toJSON(), (err, result) =>
        throw err if err?

        geo_point = new Parse.GeoPoint result.lat, result.lon
        @new_address.set 'geo_point', geo_point
      
        pizzabuttonapp.State.user.add_address @new_address
        pizzabuttonapp.State.order.set_delivery_address @new_address

        @options.next_step()

    valid: ->
      if !@get_phone_value().match(/[0-9]{10}$/)?
        return false

      if @get_street_value()=='' or @get_zip_value()==''
        return false

      true