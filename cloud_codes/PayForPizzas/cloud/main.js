var Stripe = require('stripe');

Stripe.initialize('sk_test_S8Bp85jD7McsLFgK0RxUMvUT');


var chargeCustomerForOrder = function(customer_id, order) {

};

Parse.Cloud.afterSave("Order", function(request) {
  var order = request.object;
  var card  = order.get('billing_cc');

  console.log("GOT CARD, does it need to be fetched?");
  console.log(card);

  Parse.Promise.as().then(function(){
    // Have we already created a Stripe customer for this card?
    if (card.has('stripe_customer_id')) {

      // Yes, retrieve the Customer
      return Stripe.Customers.retrieve(card.get('stripe_customer_id')).then(null, function(error){

        // In case there's any errors 
        console.error("Failed to charge order "+order.id+", could not find Stripe customer: " + error);
        return Parse.Promise.error("An error has occurred while attempting to charge your order.");
      });
    }
    else
    {
      // No, build a new Customer
      return Stripe.Customers.create({card: card.get('token')}).then(null, function(error){

        // In case there's any errors while creating the Customer
        console.error("Failed to charge order "+order.id+", could not create Stripe customer: "+error);
        return Parse.Promise.error('An error has occurred while attempting to charge your order.');
      });
    }
  }).then(function(customer){

    // Charge the customer for the order
    return Stripe.Charges.create({
      amount:   order.get('total_charge'),
      currency: 'USD',
      customer: customer.id
    }).then(null, function(error) {

      // In case there's any error while charging for this order
      console.error("Failed to charge order "+order.id+", could not create Stripe customer: "+error);
      return Parse.Promise.error('An error has occurred while attempting to charge your order.');
    });
  }).then(function(charge){
    order.save('stripe_charge_id', charge.id);

    console.log('SUCCESS: Charged order '+order.id+' with charge_id: '+charge.id);
  }, function(error){
    orer.save('stripe_charge_error', error);

    // Catches all errors at the very end. 
    console.error('FAIL: Did not charge order '+order.id+', error: '+error);
  })

});
