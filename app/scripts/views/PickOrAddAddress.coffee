'use strict';

class pizzabuttonapp.Views.PickOrAddAddressView extends pizzabuttonapp.Views.BaseView

    template: JST['app/scripts/templates/PickOrAddAddress.ejs']

    events: 
      'click .js-use-new-address':      'use_new_address'
      'click .js-use-existing-address': 'use_existing_address'
      'change [name="phone"]':          'update_phone_number'

    template_data: ->
      @new_address = new pizzabuttonapp.Models.AddressModel
        city: pizzabuttonapp.State.location.city
        state: pizzabuttonapp.State.location.state
        zip: pizzabuttonapp.State.location.zip

      existing_addresses: pizzabuttonapp.State.user.get_addresses().toJSON()
      new_address:        @new_address.toJSON()
      phone:              pizzabuttonapp.State.user.get_phone_number()

    get_street_value: ->
      @$('[name="new_address[street]"]').val()

    get_zip_value: ->
      @$('[name="new_address[zip]"]').val()

    use_existing_address: (e) =>
      id = $(e.target).data('address-id')

      address = pizzabuttonapp.State.user.get_address_by_id id

      pizzabuttonapp.State.order.set_delivery_address address 

      @options.next_step() if @phone_is_valid()  

    use_new_address: ->
      return if !@valid()

      @new_address.set 
        street: @get_street_value()
        zip:    @get_zip_value()

      lm = new LocationManager
      lm.geoCode @new_address.toJSON(), (err, result) =>
        throw err if err?

        geo_point = new Parse.GeoPoint result.lat, result.lon
        @new_address.set 'geo_point', geo_point
      
        pizzabuttonapp.State.user.add_address @new_address
        pizzabuttonapp.State.order.set_delivery_address @new_address

        @options.next_step()

    hide_errors: ->
      @$('.js-address-error').hide()
      @$('.js-phone-erorr').hide()

    valid: ->
      @hide_errors()
      valid = true

      valid = @phone_is_valid()

      if @get_street_value()=='' or @get_zip_value()==''
        @$('.js-address-error').show()
        valid = false

      valid

    phone_is_valid: ->
      @hide_errors()
      valid = true

      phone = pizzabuttonapp.State.user.get_phone_number()
      phone_valid = phone.match(/^1?[0-9]{10}$/)

      if !phone_valid?
        @$('.js-phone-erorr').show()
        valid = false

      valid

    update_phone_number: =>
      phone = @$('[name="phone"]').val()
      pizzabuttonapp.State.user.set_phone_number phone
      @phone_is_valid()
