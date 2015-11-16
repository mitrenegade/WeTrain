var Stripe = require('stripe');
var STRIPE_SECRET_DEV = 'sk_test_phPQmWWwqRos3GtE7THTyfT0'
var STRIPE_SECRET_PROD = 'sk_live_zBV55nOjxgtWUZsHTJM5kNtD'
Stripe.initialize(STRIPE_SECRET_PROD);

var sendMail = function(from, fromName, text, subject) {
    var Mandrill = require('mandrill');
    Mandrill.initialize('aC8uXsVJlJHJw46uo8kTqA');

    console.log("sending to " + from + " with text " + text)

    Mandrill.sendEmail({
        message: {
            text: text,
            subject: subject,
            from_email: from,
            from_name: fromName,
            to: [
            {
                email: "bobbyren@gmail.com",
                name: "WeTrain Dispatch"
            }
            ]
        },
        async: true
    },{
        success: function(httpResponse) {
            console.log("mandril email sent successfully")
            console.log(httpResponse);
        },
        error: function(httpResponse) {
            console.log("mandril email error")
            console.error(httpResponse);
        }
    });
}

var sendPushWorkout = function(clientId, requestId, testing) {
    console.log("inside send push")
    var message = "New training request available"
    if (testing == 1) {
        message = "TEST: new training request available"                    
    }
    Parse.Push.send({
        channels: [ "Trainers" ],
        data: {
            alert: message,
            client: clientId,
            request: requestId,
            sound: "default"
        }
    }, {
        success: function()
        {
            console.log("Push to Trainers successful")
            },
        error: function(error) {
            // Handle error
            console.log("Push to Trainers failed" + error)
            }
        });
    }



var randomPasscode = function() {
    return "workout"
}

Parse.Cloud.define("acceptWorkoutRequest", function(request, response) {
    var trainerId = request.params.trainerId
    var trainingObjectId = request.params.workoutId
    console.log("training request = " + trainingObjectId + " Trainer " + trainerId)

    var trainerQuery = new Parse.Query("Trainer")
    var trainerObject
    trainerQuery.get(trainerId, {
        success: function(object){
            trainerObject = object
            var trainingQuery = new Parse.Query("Workout");
            trainingQuery.get(trainingObjectId, {
                success: function(trainingObject) {
                    console.log("found training request with id " + trainingObjectId)
                    var existingTrainer = trainingObject.get("trainer")
                    if (existingTrainer == undefined || existingTrainer == trainerId) {
                        console.log("no trainer - you are it")
                        trainingObject.set("trainer", trainerObject)
                        trainingObject.set("status", "matched")
                        trainerObject.set("workout", trainingObject)
                        Parse.Object.saveAll([trainingObject, trainerObject], {
                            success: function(objects) {
                                response.success()
                            }, error: function(objects, error) {
                                response.success()
                            }
                        });
                    }
                    else {
                        console.log("Trainer already exists!")
                        response.error()
                    }
                }
                ,
                error : function(error) {
                    console.error("errrrrrrrr" + error);
                    response.error()
                }
            });
        },
        error: function(error) {

        }
    })
})


Parse.Cloud.afterSave("Feedback", function(request) {
    var feedback = request.object
    console.log("Feedback id: " + feedback.id )
    console.log("Message: " + feedback.get("message"))
    console.log("feedback email " + feedback.get("email"))

    var subject = "Feedback received"
    var text = "Feedback id: " + feedback.id + "\nMessage: \n" + feedback.get("message")

    email = feedback.get("email")
    fromName = email
    sendMail(email, fromName, text, subject)
});

Parse.Cloud.beforeSave("Workout", function(request, response) {
    var trainingObject = request.object

    if (trainingObject.get("passcode") == undefined) {
        trainingObject.set("passcode", randomPasscode())
        console.log("added passcode " + trainingObject.get("passcode") + " to training object " + trainingObject.id)
    }
    if (trainingObject.get("status") == "training" && trainingObject.get("start") == undefined) {
        var start = new Date()
        trainingObject.set("start", start)
        console.log("started training " + trainingObject.id + " at " + start)
    }
    response.success()
});

Parse.Cloud.afterSave("Workout", function(request, response) {
    var trainingObject = request.object
    console.log("Workout id: " + trainingObject.id )
    console.log("Lat: " + trainingObject.get("lat") + " Lon: " + trainingObject.get("lon"))
    console.log("Time: " + trainingObject.get("time"))
    console.log("status: " + trainingObject.get("status"))
    console.log("notified: " + trainingObject.get("notified"))

    var status = trainingObject.get("status")
    if (status == "cancelled") {
        console.log("cancelled ==================")
        return
    }

    // send push notification
        console.log("New training object: " + trainingObject + " id: " + trainingObject.id + " notified " + trainingObject.get("notified"))
    if (status == "requested" && (trainingObject.get("notified") == undefined || trainingObject.get("notified") == false)) {
        var clientObject = trainingObject.get("client")
        var clientQuery = new Parse.Query("Client");
        clientQuery.get(clientObject.id, {
            success: function(client) {
                console.log("Client object: " + clientObject + " id: " + clientObject.id)
                email = client.get("email")
                if (email == undefined) {
                    email = "bobbyren+WeTrain@gmail.com"
                }
                fromName = client.get("firstName")
                if (fromName == undefined) {
                    fromName = "WeTrain Team"
                }
                var testing = trainingObject.get("testing")
                sendPushWorkout(clientObject.id, trainingObject.id, testing)
            }
            ,
            error : function(error) {
                console.error("errrrrrrrr" + error);
                email = "bobbyren+WeTrain@gmail.com"
                fromName = "WeTrain Team"
            }
        });
        trainingObject.set("notified", true)
        trainingObject.save()
    }
    else {
        console.log("Training object aftersave not sending notification")
    }
});

Parse.Cloud.afterSave("Client", function(request, response) {
    var client = request.object
    var customerId = client.get("customer_id")
    if (customerId == undefined || customerId == "") {
        createCustomer(client, response)
    }
    else {
        console.log("afterSave client not creating customer because:: customerId " + customerId)
    }
});

var Customer = Parse.Object.extend('Customer');
var createCustomer = function(client, response) {
    console.log("creating customer for client " + client.id + " token " + client.get("stripeToken"))
    var token = client.get("stripeToken")
    Stripe.Customers.create({
        card: token // the token id should be sent from the client
    },{
        success: function(httpResponse) {
            console.log(httpResponse);
            var customer_id = httpResponse["id"]
            var card = httpResponse.default_source
            client.set("customer_id", customer_id)
            client.set("card", card)
            client.save().then(
                function(object) {
                    console.log("client saved with customer id " + client.get("customer_id"))
                }, 
                function(error) {
                    console.log("customer failed to save " + error)
                }
            )
        },
        error: function(httpResponse) {
            console.log(httpResponse);
            response.error("Uh oh, something went wrong"+httpResponse);
        }
    });
}

Parse.Cloud.define("startWorkout", function(request, response) {
    var workoutId = request.params.workoutId
    var clientId = request.params.clientId;

    console.log("workout = " + workoutId)

    var query = new Parse.Query("Workout")
    query.get(workoutId, {
        success: function(workout){
            var amt = 0.0
            if (workout.get("length") == 60) {
                amt = 1.0 //22.0
            }
            else {
                amt = 0.5 //17.0
            }
            chargeCustomerBeforeStartingWorkout(clientId, workout, amt, {
                success: function() {
                    workout.set("status", "training")
                    workout.save().then(function(workout) {
                        console.log("workout started: status " + workout.get("status"))
                        response.success(workout)
                    });
                },
                error: function(error) {
                    console.log("chargeCustomerBeforeStartingWorkout failed: " + error)
                    response.error(error)
                }
            })
        },
        error: function(error) {
            console.log("startWorkout could not find workout " + workoutId)
            response.error(error)
        }
    })
})

var chargeCustomerBeforeStartingWorkout = function(clientId, workout, amt, response){
    var query = new Parse.Query("Client")
    query.get(clientId, {
        success: function(client){
            // create payment
            createPaymentForWorkout(client, workout, amt, {
                success: function(payment) {
                    workout.set("payment", payment)
                    workout.save().then(
                        function(object) {
                            console.log("workout saved with payment id " + workout.get("payment").id)
                            if (payment.get("charged") == undefined || payment.get("charged") == false || payment.get("chargeId") == undefined || payment.get("chargeId") == "") {
                                // charge customer
                                var customer = client.get("customer_id")
                                console.log("client " + client.id + " customer " + client.get("customer_id"))
                                createCharge(customer, payment, {
                                    success: function(chargeId) {
                                        response.success()
                                    }, 
                                    error: function(error) {
                                        console.log("charge card failed")
                                        response.error(error)
                                    }
                                })
                            }
                            else {
                                // payment was already successfully charged
                                console.log("payment was already completed. do not double charge: continue with workout")
                                response.success()
                            }
                        }, 
                        function(error) {
                            console.log("workout failed to save with payment. error: " + error)
                        }
                    )
                },
                error: function(error) {
                    console.log("could not create payment: " + error)
                    response.error(error)
                }
            })
        },
        error: function(error) {
            console.log("could find client " + clientId)
            response.error(error)
        }
    })
}

var Payment = Parse.Object.extend('Payment');
var createPaymentForWorkout = function(client, workout, amount, response) {
    console.log("inside create payment for workout: " + workout.id + " client: " + client.id + " customer " + client.get("customer_id"))

    var payment = workout.get("payment")
    if (payment == undefined) {
        console.log("No payment exists")
        payment = new Payment()
        payment.set("client", client)
        payment.set("workout", workout)
        payment.set("amount", amount)
        payment.set("charged", false)
        console.log("created new payment...")
        payment.save().then(
            function(payment) {
                console.log("payment saved with id " + payment.id + " charged " + payment.charged)
                response.success(payment)
            }, 
            function(error) {
                console.log("payment failed to save " + error)
                response.error(error)
            }
        )
    }
    else {
        console.log("updating existing payment with id " + payment.id + " charged " + payment.charged + " " + payment.get("chargeId"))
        var query = new Parse.Query("Payment")
        query.get(payment.id, {
            success: function(object) {
                payment = object
                console.log("existing payment " + payment.id + " was charged " + payment.charged + " " + payment.get("chargeId"))
                response.success(payment)
            }
            , error: function(error) {
                console.log("could not load payment")
                response.error(error)
            }
        })
    }
}

var createCharge = function(customer, payment, response) {
    var amt = payment.get("amount")
    Stripe.Charges.create({
        amount: amt * 100.00, // expressed in minimum currency unit (cents)
        currency: "usd",
        customer: customer
    },{
        success: function(httpResponse) {
            console.log("stripe purchase made id: " + httpResponse.id)
            var chargeId = httpResponse.id
            // fulfill payment
            payment.set("charged", true)
            payment.set("chargeId", chargeId)
            payment.save()
            response.success();
        },
        error: function(error) {
            console.log("stripe purchase error " + error)
            payment.set("charged", false)
            payment.set("stripeError", error) // record stripe error
            payment.save()
            response.error(error);
        }
    });

}
//curl -X POST -H "X-Parse-Application-Id: mxzbQxv3lYPBJoOpbnkMDgnDoFFkFuUW6Sm3Of9d" -H "X-Parse-REST-API-Key: v4uFmG5hgfhJKejsDqLBRFbq15gWBxnA6yZd9Dvm" -H "Content-Type: application/json" -d '{"toEmail":"bobbyren@gmail.com","toName":"Bobby Ren","fromEmail":"bobbyren@gmail.com","fromName":"Bobby Ren","text":"testing ManDrill email","subject":"this is just a test"}' https://api.parse.com/1/functions/sendMail