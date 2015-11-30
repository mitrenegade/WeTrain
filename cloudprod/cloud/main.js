var Stripe = require('stripe');
var STRIPE_SECRET_DEV = 'sk_test_phPQmWWwqRos3GtE7THTyfT0'
var STRIPE_SECRET_PROD = 'sk_live_zBV55nOjxgtWUZsHTJM5kNtD'
Stripe.initialize(STRIPE_SECRET_PROD);

var sendMail = function(from, fromName, text, subject) {
    var Mandrill = require('mandrill');
    Mandrill.initialize('aC8uXsVJlJHJw46uo8kTqA');

    console.log("SENDMAIL: sending to " + from + " with text " + text)

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
            console.log("SENDMAIL: mandril email sent successfully")
            console.log(httpResponse);
        },
        error: function(httpResponse) {
            console.log("mandril email error: " + httpResponse)
            console.error(httpResponse);
        }
    });
}

var sendPushWorkoutTrainer = function(clientId, requestId, testing) {
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

var sendPushWorkoutClient = function(trainerId, requestId, testing) {
    console.log("inside send push")
    var message = "A trainer has accepted your session"
    if (testing == 1) {
        message = "TEST: a trainer has accepted your session"                    
    }
    var channelName = "workout_" + requestId
    console.log("client channel: " + channelName)
    Parse.Push.send({
        channels: [ channelName ],
        data: {
            alert: message,
            trainer: trainerId,
            request: requestId,
            sound: "default"
        }
    }, {
        success: function()
        {
            console.log("Push to Client successful")
            },
        error: function(error) {
            // Handle error
            console.log("Push to Client failed" + error)
            }
        });
    }


var randomPasscode = function() {
    var passcodes = ["sweat", "workout", "absofsteel", "circuit", "training", "marathon", "sprint", "6pack", "crunches", "warmup", "routine", "winning", "swimsuit", "beachbody", "gametime"]
//    for (var i = 0; i < 100; i++) {
    var index = Math.floor(Math.random() * passcodes.length)
    console.log("random passcode index " + index + " code " + passcodes[index])
//    }
    return passcodes[index]
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
                                var testing = trainingObject.get("testing")
                                console.log("ACCEPT_WORKOUT_REQUEST sending push to " + trainerObject.id + " " + trainingObject.id + " testing " + testing)
                                sendPushWorkoutClient(trainerObject.id, trainingObject.id, testing)
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
    console.log("beforeSave workout status " + trainingObject.get("status"))
    /*
    // TODO: allow clients to request a workout and handle failure on trainer's side, until client's app is released
    if (trainingObject.get("status") == "requested") {
        var client = trainingObject.get("client")
        var customerId = client.get("customer_id")
        console.log("beforeSave client customer_id: " + customerId)
        if (customerId == undefined || customerId == "") {
            response.error("Your payment method is invalid; please reenter your credit card")
        }
        else {
            response.success()                
        }
    }
    else {
        response.success()
    } 
    */
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
                sendPushWorkoutTrainer(clientObject.id, trainingObject.id, testing)
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

Parse.Cloud.beforeSave("Client", function(request, response) {
    var client = request.object
    console.log("CLIENT_BEFORESAVE: client " + client.id)    
    response.success()
})

Parse.Cloud.afterSave("Client", function(request, response) {
    var client = request.object
    console.log("CLIENT_AFTERSAVE: client " + client.id)    
    // backwards compatibility with client 0.7.0: if clients are created with no customer_id, try saving their customer id
    // this doesn't allow 0.7.0 to update their credit card; 0.7.1 must call updatePayment to update credit card
    var customerId = client.get("customer_id")
    if ((customerId == undefined || customerId == "") && (client.get("stripeToken") != undefined)) {
        console.log("CLIENT_AFTERSAVE: calling createCustomer with token " + client.get("stripeToken"))
        createCustomer(client, {
            success: function(success) {
                console.log("CLIENT_AFTERSAVE: client " + client.id + " saved with customer")
            },
            error: function(error) {
                console.log("CLIENT_AFTERSAVE: client failed to create customer with error " + error)
                response.error(error)
            }
        })
    }
})

Parse.Cloud.define("updatePayment", function(request, response) {
    var clientId = request.params.clientId
    var stripeToken = request.params.stripeToken
    var query = new Parse.Query("Client")
    console.log("UPDATE_PAYMENT: client " + clientId + " token " + stripeToken)
    query.get(clientId, {
        success: function(client){
            createCustomer(client, {
                success: function(success) {
                    console.log("UPDATE_PAYMENT: client saved with customer " + client.get("customer_id"))
                    response.success()
                },
                error: function(error) {
                    console.log("UPDATE_PAYMENT: client failed to create customer with error " + error)
                    client.unset("stripeToken")
                    client.unset("stripeFour")
                    client.unset("card")
                    client.unset("customer_id")
                    client.save()

                    response.error(error)
                }
            })
        },
        error: function(error) {
            console.log("UPDATE_PAYMENT: Error loading client " + clientId)
        }
    })
})

var createCustomer = function(client, response) {
    var token = client.get("stripeToken")
    Stripe.Customers.create({
        card: token // the token id should be sent from the client
    },{
        success: function(httpResponse) {
            var customer_id = httpResponse["id"]
            var card = httpResponse.default_source
            console.log("CREATE_CUSTOMER: created customer for client " + client.id + " token " + client.get("stripeToken"))
            client.set("customer_id", customer_id)
            client.set("card", card)
            client.unset("stripeToken")
            client.save().then(
                function(object) {
                    console.log("CREATE_CUSTOMER: client id " + client.id + " saved with customer id " + client.get("customer_id"))
                    response.success()
                }, 
                function(error) {
                    console.log("CREATE_CUSTOMER: customer failed to save " + error)
                    response.error("Could not save your credit card to your account. Please try again.")
                }
            )
        },
        error: function(httpResponse) {
            console.log("CREATE_CUSTOMER: Stripe.Customers.Create failed: " + httpResponse);
            response.error("Please check your credit card number and try again.")
        }
    });
}

Parse.Cloud.define("startWorkout", function(request, response) {
    var workoutId = request.params.workoutId
    var clientId = request.params.clientId;

    var query = new Parse.Query("Workout")
    query.get(workoutId, {
        success: function(workout){
            var amt = 0.0
            if (workout.get("length") == 60) {
                amt = 25.0
            }
            else {
                amt = 17.0
            }
            chargeCustomerBeforeStartingWorkout(clientId, workout, amt, {
                success: function() {
                    workout.set("status", "training")
                    workout.save().then(function(workout) {
                        console.log("START_WORKOUT: workout started: id " + workoutId + " status " + workout.get("status"))
                        response.success(workout)
                    });
                },
                error: function(error) {
                    console.log("CHARGE_CUSTOMER_BEFORE_STARTING_WORKOUT: error " + error)
                    response.error(error)
                }
            })
        },
        error: function(error) {
            console.log("START_WORKOUT: could not find workout " + workoutId)
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
                            console.log("CHARGE_CUSTOMER_BEFORE_STARTING_WORKOUT: workout saved with payment id " + workout.get("payment").id)
                            if (payment.get("charged") == undefined || payment.get("charged") == false || payment.get("chargeId") == undefined || payment.get("chargeId") == "") {
                                // charge customer
                                createCharge(client, payment, {
                                    success: function(chargeId) {
                                        response.success()
                                    }, 
                                    error: function(error) {
                                        response.error(error)
                                    }
                                })
                            }
                            else {
                                // payment was already successfully charged
                                console.log("CHARGE_CUSTOMER_BEFORE_STARTING_WORKOUT: payment was already completed. do not double charge: continue with workout")
                                response.success()
                            }
                        }, 
                        function(error) {
                            console.log("CHARGE_CUSTOMER_BEFORE_STARTING_WORKOUT: workout failed to save with payment. error: " + error)
                        }
                    )
                },
                error: function(error) {
                    response.error(error)
                }
            })
        },
        error: function(error) {
            console.log("CHARGE_CUSTOMER_BEFORE_STARTING_WORKOUT: could not find client " + clientId)
            response.error(error)
        }
    })
}

var Payment = Parse.Object.extend('Payment');
var createPaymentForWorkout = function(client, workout, amount, response) {

    var payment = workout.get("payment")
    if (payment == undefined) {
        console.log("CREATE_PAYMENT_FOR_WORKOUT: create new payment for workout: " + workout.id + " client: " + client.id + " customer " + client.get("customer_id"))
        payment = new Payment()
        payment.set("client", client)
        payment.set("workout", workout)
        payment.set("amount", amount)
        payment.set("charged", false)
        payment.save().then(
            function(payment) {
                console.log("CREATE_PAYMENT_FOR_WORKOUT: payment saved with id " + payment.id + " charged " + payment.charged)
                response.success(payment)
            }, 
            function(error) {
                console.log("CREATE_PAYMENT_FOR_WORKOUT: payment failed to save. Error: " + error)
                response.error(error)
            }
        )
    }
    else {
        console.log("CREATE_PAYMENT_FOR_WORKOUT: updating existing payment with id " + payment.id + " charged " + payment.charged + " " + payment.get("chargeId"))
        var query = new Parse.Query("Payment")
        query.get(payment.id, {
            success: function(object) {
                payment = object
                console.log("CREATE_PAYMENT_FOR_WORKOUT: existing payment " + payment.id + " was charged " + payment.charged + " " + payment.get("chargeId"))
                response.success(payment)
            }
            , error: function(error) {
                console.log("CREATE_PAYMENT_FOR_WORKOUT: could not load payment. Error: " + error)
                response.error(error)
            }
        })
    }
}

var createCharge = function(client, payment, response) {
    var customer = client.get("customer_id")
    console.log("CREATE_CHARGE: client " + client.id + " customer " + client.get("customer_id") + " paymentOverride " + client.get("paymentOverride"))

    var amt = payment.get("amount")
    var successFunc = function(httpResponse) {
        console.log("CREATE_CHARGE success response: " + httpResponse)
        var chargeId = httpResponse.id;
        // fulfill payment
        payment.set("charged", true);
        payment.set("chargeId", chargeId);
        payment.save();
        response.success();
    }

    if (client.get("paymentOverride") == true) {
        console.log("CREATE_CHARGE: client override skipping create payment")
        var httpResponse = {id: "no_charge"}
        successFunc(httpResponse)
    }
    else {
        console.log("creating charge for client")
        Stripe.Charges.create({
            amount: amt * 100.00, // expressed in minimum currency unit (cents)
            currency: "usd",
            customer: customer
        },{
            success: successFunc,
            error: function(error) {
                console.log("CREATECHARGE: stripe purchase error " + error)
                payment.set("charged", false)
                payment.set("stripeError", error) // record stripe error
                payment.save()
                response.error("Credit card could not be charged. Ask client to reenter their payment info.");
            }
        });
    }
}
//curl -X POST -H "X-Parse-Application-Id: mxzbQxv3lYPBJoOpbnkMDgnDoFFkFuUW6Sm3Of9d" -H "X-Parse-REST-API-Key: v4uFmG5hgfhJKejsDqLBRFbq15gWBxnA6yZd9Dvm" -H "Content-Type: application/json" -d '{"toEmail":"bobbyren@gmail.com","toName":"Bobby Ren","fromEmail":"bobbyren@gmail.com","fromName":"Bobby Ren","text":"testing ManDrill email","subject":"this is just a test"}' https://api.parse.com/1/functions/sendMail