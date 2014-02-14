// Initialize modules
var Stripe = require('stripe');
Stripe.initialize('sk_test_Lf3CEX3liEWOr0v0LSO0nnOy');

var Mailgun = require('mailgun');
Mailgun.initialize("sandbox74731.mailgun.org", "key-3ir7uu4-blgsx6b712ke5a4epgv5lfx0");

// Purchase endpoint for the photo album
Parse.Cloud.define("purchaseItem", function(request, response) {
	// Get the album object
	var query = new Parse.Query('Album');
	query.equalTo('objectId', request.params.album);
	query.first({
		success: function(album) {
		    // Create an order
		    order = new Parse.Object('Order');
		    order.set('quantity', request.params.quantity);
		    order.set('album', album);
		    order.set('price', request.params.price);
		    order.set('total', request.params.total);
		    order.set('cardToken', request.params.cardToken);
		    order.set('name', request.params.name);
		    order.set('email', request.params.email);
		    order.set('address', request.params.address);
		    order.set('zip', request.params.zip);
		    order.set('city', request.params.city);
		    order.set('state', request.params.state);
		    order.set('fulfilled', false);
		    order.set('charged', false);
			order.save(null, {
				success: function(httpResponse) {
					console.log("Beginning to charge Stripe");
					// Create a Stripe charge with the card token
					Stripe.Charges.create({
						amount: request.params.total * 100, // in cents
				  		currency: "USD",
				  		card: request.params.cardToken // the token ID is sent from the client
					}, {
							success: function(httpResponse) {
						  	  	console.log(httpResponse);
						    	
						    	// Credit card was charged. Now we save the ID of the purchase on our
						    	// order.
						    	order.set('stripePaymentId', httpResponse.id);
						    	order.set('charged', true);
						    	order.save(null, {
						    		success: function(httpResponse) {
						    			// Send a confirmation email
										body = "Purchase made!";
										Mailgun.sendEmail({
											to: request.params.email,
											from: 'store@albums.com',
											subject: 'Your order for ' + album.get('title'),
											text: body
										});
										response.success("Purchase made!");
							    	},
							    	error: function(httpResponse) {
							    		console.log(httpResponse);
							    		response.error("Sorry, could not save the order. Please try again.");
							    	}
						    	});
					  		},
					  		error: function(httpResponse) {
					  			console.log(httpResponse);
			    				response.error("Sorry, could not charge your credit card. Please try again.");
					  		}
					});
				},
				error: function(httpResponse) {
					console.log(httpResponse);
					response.error("Sorry, could not create a new order. Please try again.");
				}
			});
		},
		error: function(error) {
			console.log(error);
			response.error("Sorry, could not retrieve the album. Please try again.");	
		}
	});
});
