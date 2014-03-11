// Initialize modules
var Stripe = require('stripe');
Stripe.initialize('sk_test_Lf3CEX3liEWOr0v0LSO0nnOy');

var Mailgun = require('mailgun');
Mailgun.initialize('sandbox74731.mailgun.org', 'key-3ir7uu4-blgsx6b712ke5a4epgv5lfx0');

// Purchase endpoint for the photo album order
Parse.Cloud.define('purchaseItem', function(request, response) {
	// Get the order object
	var query = new Parse.Query('Order');
	query.equalTo('objectId', request.params.order);
    query.include('album');
	query.first({
		success: function(order) {
            console.log('Got order ' + JSON.stringify(order));
		    // Start charging the card
			order.save(null, {
				success: function(httpResponse) {
					// Create a Stripe charge with the card token
                    console.log('Charging order for ' + order.get('total'));
					Stripe.Charges.create({
						amount: order.get('total') * 100, // in cents
                        currency: 'USD',
				  		card: order.get('cardToken') // the token ID is sent from the client
					}, {
							success: function(httpResponse) {
                                console.log('Charged ' + httpResponse);
						    	// Credit card was charged. Save the payment token.
						    	order.set('paymentToken', httpResponse.id);
						    	order.set('charged', true);
						    	order.save(null, {
						    		success: function(httpResponse) {
						    			// Send a confirmation email
                                        console.log('Purchase success ' + httpResponse);
										body = 'Purchase made!';
										Mailgun.sendEmail({
											to: order.get('email'),
											from: 'store@memoriesapp.com',
											subject: 'Your order for ' + order.get('album').get('title'),
											text: body
										});
										response.success('Purchase made!');
							    	},
							    	error: function(httpResponse) {
							    		console.log(httpResponse);
							    		response.error('Sorry, could not save the order. Please try again.');
							    	}
						    	});
					  		},
					  		error: function(httpResponse) {
					  			console.log('Purchase error ' + httpResponse);
			    				response.error('Sorry, could not charge your credit card. Please try again.');
					  		}
					});
				},
				error: function(httpResponse) {
					console.log(httpResponse);
					response.error('Sorry, could not save the order. Please try again.');
				}
			});
		},
		error: function(error) {
			console.log(error);
			response.error('Sorry, could not retrieve the order. Please try again.');
		}
	});
});
