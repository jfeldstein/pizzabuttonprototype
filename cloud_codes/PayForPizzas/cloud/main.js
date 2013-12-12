var Stripe = require('stripe');
var Mailgun = require('mailgun');
var fs = require('fs');
var _ = require('underscore');

Mailgun.initialize('thepizzabutton.com', 'key-25baubdiq0gvqg0pdhxkt34uevb1viz1');
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
    return response.error('An error has occurred while attempting to save this card. Please try again.');
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
  if(order.has('stripe_chargeid')) {
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
      return Parse.Promise.error("NO_CUSTOMER_ID");
    }

    // Charge the customer for the order
    return Stripe.Charges.create({
      amount:   order.get('total_charge')*100, // integer cents
      currency: 'USD',
      customer: card.get('stripe_customerid')
    }).then(function(charge){
      console.log("Charge '"+charge.id+"' successfull.");
      return Parse.Promise.as(charge);
    }, function(charge_error){
      for( i in arguments ) {
        for( j in arguments[i] ) {
          console.log(i+", "+j+" "+arguments[i][j]);
        }
      }
      console.error("Error charging stripe_customerid '"+card.get('stripe_customerid')+"'. Error: '"+charge_error+"'");
      return Parse.Promise.error("CHARGE_FAILED");
    })
  })

  // 2. Get all the data needed to send the email
  .then(function(charge){
    var promises = [charge];

    var rest_promise = new Parse.Promise();
    var addr_promise = new Parse.Promise();
    var cust_promise = new Parse.Promise(); 

    order.get('restaurant').fetch({
      success: function(restaurant){
        return rest_promise.resolve(restaurant);
      },
      error: function(){
        return rest_promise.reject('Failed to fetch restaurant');
      }
    });

    order.get('delivery_address').fetch({
      success: function(address){
        return addr_promise.resolve(address);
      },
      error: function(){
        return addr_promise.reject('Failed to fetch address');
      }
    });

    order.get('customer').fetch({
      success: function(customer){
        return cust_promise.resolve(customer);
      },
      error: function(){
        return cust_promise.reject('Failed to fetch customer');
      }
    });

    return Parse.Promise.when([charge, rest_promise, addr_promise, cust_promise]);
  })

  // 3. Send the email
  .then(function(charge, restaurant, delivery_address, customer){

    order.set('stripe_chargeid', charge.id);

    var template = fs.readFileSync("cloud/order_email.ejs");

    var pizzas = _.map(order.get('pizzas'), function(d, type){
      return {
        type: type,
        quantity: d.quantity,
        size: d.size_id
      };
    });

    var cust_data = {
      name: customer.get('name'),
      phone_number: order.get('phone_number'),
      address: delivery_address.get('street') + ' in ' + delivery_address.get('city')
    };

    var rest_data = {
      name: restaurant.get('name'),
      phone: restaurant.get('phone_number')
    };

    var email_content = _.template(template, {
      restaurant: rest_data,
      pizzas:     pizzas,
      customer:   cust_data,
      tip:        order.get('selected_tip'),
      cc:         {
        number:     '4242 4242 4242 4242',
        exp_month:  '08',
        exp_year:   '15',
        cvc:        '123'
      }
    });

    return Mailgun.sendEmail({
      to: "orders@thepizzabutton.com",
      from: "Mailgun@CloudCode.com",
      subject: "New Order!",
      text: email_content
    }).then(function(){

      // Successfully charged the order and delivered the email: 
      console.log('SUCCESS: Charged order with charge_id: '+charge.id +' and delivered order to orders@tpb');
      return Parse.Promise.as('Success');

    }, function(email_error){
      // Email failed, rollback the charge

      console.error("Sending order email failed. Error:'"+email_error+"'. Refunding charge "+charge.id);
      order.set('charge_refunded_at', new Date());

      return Stripe.Charges.refund(charge.id, order.get('total_charge')*100).then(function(){
        console.log("Charge "+charge.id+" has been sucessfully refunded.");
        return Parse.Promise.error('DELIVERY_FAILURE');

      }, function(refund_error){
        console.error("Charge "+charge.id+" for order "+order.id+" failed to refund! Error:'"+refund_error+"'");
        order.set('refund_error', refund_error);
        return Parse.Promise.error('DELIVERY_AND_REFUND_FAILURE');
      })
    });
  })

  
  // 4. Cleanup and save whatever happened
  .then(function(){
    // Save the object
    order.set('successfully_placed', true);
    return response.success();
  }, function(error){
    // Save the object anyway, the client will deduce if everything worked. 
    console.log("Setting order error to:")
    console.log(error)

    order.set('successfully_placed', false);
    order.set('error', error);

    return response.success();
  });
});
