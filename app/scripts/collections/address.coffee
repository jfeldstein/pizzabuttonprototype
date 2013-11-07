'use strict';

class pizzabuttonapp.Collections.AddressCollection extends Parse.Collection
  model: pizzabuttonapp.Models.AddressModel

  query: (new Parse.Query(pizzabuttonapp.Models.AddressModel)).equalTo("user", Parse.User.current())
