var Stripe = require('stripe');
var Mailgun = require('mailgun');

Mailgun.initialize('thepizzabutton.com', '4drhb3r0h4m4');
Stripe.initialize('sk_test_S8Bp85jD7McsLFgK0RxUMvUT');


var chargeCustomerForOrder = function(customer_id, order) {

};

// Create a Stripe customer for each card while saving for the first time. 
// If there's any trouble making the customer, the save will fail and the UI
// can try again.
Parse.Cloud.beforeSave("CreditCard", function(request, response) {
  var card = request.object;

  // Check for customer ID
  if(card.has('stripe_customerid')) {
    return response.success();
  }

  console.log("attempting to create stripe customer from card "+card.get('token'));
  
  Stripe.Customers.create({
    card: card.get('token')

  }).then(function(customer){
    // Add customer ID to card
    console.log("Created Customer: "+customer.id);
    card.set('stripe_customerid', customer.id);
    return response.success();

  }, function(error){
    // In case there's any errors while creating the Customer
    console.error("Could not create Stripe customer: "+error);
    return response.error('An error has occurred while attempting to save this card.');
  });
});


// When the order is placed, attempt to charge the customer. 
// If the order's already been charged, do nothing / allow save.
// If the order's card doesn't have a Customer ID, we're in a bad state. Fail the order and complain.
// Attempt to charge the order.
// If the charge fails, reject the save and respond with an error. 
// If the charge succeeds, send the email. 
//  If the email succeeds, respond with success. 
//  If the email fails, rollback the charge and reject the save.
//    If the rollback fails, freak the fuck out. 
Parse.Cloud.beforeSave("Order", function(request, response) {
  var order = request.object;
  var card  = order.get('billing_cc');

  // Don't double charge orders
  if(order.has('stripe_charge_id')) {
    return response.success();
  }


  Parse.Promise.as().then(function(){
    return card.fetch();
  })
  
  // 1. Charge the order.
  .then(function(){
    // Reject the order if card doesn't already have a customer ID 
    // Bad State.
    if(!card.has('stripe_customerid')) {
      return Parse.Promise.error("Cannot charge Order to a cc with no Customer ID");
    }

    // Charge the customer for the order
    return Stripe.Charges.create({
      amount:   order.get('total_charge')*100, // integer cents
      currency: 'USD',
      customer: card.get('stripe_customerid')
    }).then(null, function(charge_error){
      console.error("Error charging stripe_customerid '"+card.get('stripe_customerid')+"'. Error: '"+charge_error+"'");
      return Parse.Promise.error("Charge Failed");
    })
  })

  // 2. Send the email
  .then(function(charge){
    order.set('stripe_chargeid', charge.id);

    return Mailgun.sendEmail({
      to: "orders@thepizzabutton.com",
      from: "Mailgun@CloudCode.com",
      subject: "New Order!",
      text: "Using Parse and Mailgun is great!"
    }).then(function(){

      // Successfully charged the order and delivered the email: 
      console.log('SUCCESS: Charged order '+order.id+' with charge_id: '+charge.id +' and delivered order to orders@tpb');
      return Parse.Promise.as('Success');

    }, function(email_error){
      // Email failed, rollback the charge

      console.error("Sending order email for order "+order.id+" failed. Error:'"+email_error+"'. Refunding charge "+charge.id);
      order.set('charge_refunded_at', new Date());

      return Stripe.Charges.refund(charge.id, order.get('total_charge')).then(function(){
        console.log("Charge "+charge.id+" has been sucessfully refunded.");
        return Parse.Promise.as('Failed to deliver. Refunded.');

      }, function(refund_error){
        order.set('refund_error', refund_error);
        console.error("Charge "+charge.id+" for order "+order.id+" failed to refund! Error:'"+refund_error+"'");
        return Parse.Promise.as('Failed to deliver. Failed to refund!');
      })
    });
  })

  
  // 3. Cleanup and save whatever happened
  .then(function(){
    // Save the object
    return response.success();
  }, function(){
    // Save the object anyway, the client will deduce if everything worked. 
    return response.success();
  });
});
