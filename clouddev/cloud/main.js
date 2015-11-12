var Stripe = require('stripe');
var STRIPE_SECRET_DEV = 'sk_test_phPQmWWwqRos3GtE7THTyfT0'
var STRIPE_SECRET_PROD = 'sk_live_zBV55nOjxgtWUZsHTJM5kNtD'
Stripe.initialize(STRIPE_SECRET_DEV);

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

    var status = trainingObject.get("status")
    if (status == "cancelled") {
        console.log("cancelled ==================")
        return
    }

    var subject = "Training requested"
    if (status == "none") {
        subject = "Training cancelled"
    }

    var testing = trainingObject.get("testing")

    var text = "Workout id: " + trainingObject.id + " Status: " + status + "\nLat: " + trainingObject.get("lat") + " Lon: " + trainingObject.get("lon") + "\nTime: " + trainingObject.get("time")

    var clientObject = trainingObject.get("client")
    var clientQuery = new Parse.Query("Client");
    clientQuery.get(clientObject.id, {
        success: function(client) {
            email = client.get("email")
            if (email == undefined) {
                email = "bobbyren+WeTrain@gmail.com"
            }
            fromName = client.get("firstName")
            if (fromName == undefined) {
                fromName = "WeTrain Team"
            }

            // sending email
            if (status == "requested" || status == "cancelled") {
                console.log("training request by user " + email + " with status " + status)
                sendMail(email, fromName, text, subject)
            }

            // send push notification
            console.log("Client object: " + clientObject + " id: " + clientObject.id)
            console.log("Training object: " + trainingObject + " id: " + trainingObject.id)
            sendPushWorkout(clientObject.id, trainingObject.id, testing)

            // payment
            /*
            if (status == "completed") {
                token = client.get("stripeToken")
                console.log("token " + token)
                createPaymentForWorkout(request, response, trainingObject, client)
            }
            */

        }
        ,
        error : function(error) {
            console.error("errrrrrrrr" + error);
            email = "bobbyren+WeTrain@gmail.com"
            fromName = "WeTrain Team"
            sendMail(email, fromName, text, subject)
        }
    });
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
    console.log("workout = " + workoutId)

    var query = new Parse.Query("Workout")
    var workoutObject
    query.get(workoutId, {
        success: function(object){

            workoutObject = object
            workoutObject.set("status", "training")
            workoutObject.save().then(function(workoutObject) {
                console.log("workout started: status " + workoutObject.get("status"))

                response.success(workoutObject)
                createPaymentForWorkout(workoutObject)
            });
        },
        error: function(error) {
            console.log("could not startWorkout for " + workoutId)
            response.error(error)
        }
    })
})

var Payment = Parse.Object.extend('Payment');
var createPaymentForWorkout = function(workoutObject) {
    /*
    var clientObject = workoutObject.get("client")
    console.log("inside create payment for workout: " + workoutObject + " id: " + workoutObject.id + " client: " + clientObject + " id: " + clientObject.id + " token " + clientObject.get("stripeToken") + " last4 " + clientObject.get("lastFour"))

    var existingPayment = workoutObject.get("payment")
    if (existingPayment == undefined) {
        console.log("No payment exists")
        var payment = new Payment()
        payment.set("client", clientObject)
        payment.set("workout", workoutObject)
        var amount = 2
        payment.set("amount", amount)

        // todo: client needs to be fetched
        var query = new Parse.Query("Trainer")
        query.get(clientObject.id, {
            success: function(object){
                console.log("client object found " + object + " with token " + object.get("stripeToken"))
                var stripeToken = clientObject.get("stripeToken")
                console.log("found token: " + stripeToken)
                payment.set("stripeToken", stripeToken)

                Parse.Cloud.run('chargeCard', {
                    stripeToken: stripeToken ,
                    amount: amount,
                }, 
                {
                    success: function(ratings) {
                        //update payment object
                        payment.set("charged", true)
                        payment.set("total", payment.get("total") + amount)
                        payment.save()
                    },
                    error: function(error) {
                        var  errorMessage = "There was a problem charging your card, please try again";
                    }            
                }, 
            error: function(error) {
                console.log("client request failed")
            }
        }

        payment.set("charged", false)

        console.log("saving payment...")
        // uses promises

        // WIP: then does not get called; payments don't get saved and callbacks can't be called
        // is it because of timestamp? use a new workout
        payment.save().then(
            function(payment) {
                console.log("payment saved with id " + payment.id)
            }, 
            function(error) {
                console.log("payment failed to save " + error)
            }
        )
        /*
        payment.save().then(function(payment) {
            console.log("payment saved with id " + payment.id)

            // add payment to workout object
            console.log("saving payment to workout")
            workoutObject.set("payment", payment)

            // add payment to trainer object
            var trainerObject = workoutObject.get("trainer")
            var trainerQuery = new Parse.Query("Trainer");
            trainerQuery.get(trainerObject.id)
        })
        .then(function(trainer) {
            console.log("saving payment to trainer: " + trainer + " id: " + trainer.id)
            payment.set("trainer", trainer)
            payment.save()
            workoutObject.save()
            console.log("createPaymentForWorkout successfully saved trainer and workout with new payment")
        }, function(error) {
            console.log("could not save payment")
        });
        */
//    }
//    else {
//        console.log("payment already exists... ")
//        console.log("was charged: " + existingPayment.get("amount"))
//    }
}

Parse.Cloud.define("chargeCustomer", function(request, response){
    var clientId = request.params.clientId;
    var amt = request.params.amount;

    var query = new Parse.Query("Client")
    query.get(clientId, {
        success: function(object){
            var customer = object.get("customer_id")
            console.log("client " + object.id + " customer " + object.get("customer_id"))
            Stripe.Charges.create({
                amount: amt * 100.00, // expressed in minimum currency unit (cents)
                currency: "usd",
                customer: customer
            },{
                success: function(httpResponse) {
                    console.log("stripe purchase made")
                    response.success("Purchase made!");
                },
                error: function(error) {
                    console.log("stripe purchase error " + error)
                    response.error("Uh oh, something went wrong");
                }
            });
        },
        error: function(error) {
            console.log("could find client " + clientId)
            response.error(error)
        }
    })
/*
    console.log("stripe charging token " + client + " amount " + amt)
    Stripe.Charges.create({
        amount: amt * 100.00, // expressed in minimum currency unit (cents)
        currency: "usd",
        card: stripeToken // the token id should be sent from the client
        },{
            success: function(httpResponse) {
                console.log("stripe purchase made")
                response.success("Purchase made!");
            },
            error: function(error) {
                console.log("stripe purchase error " + error)
                response.error("Uh oh, something went wrong");
            }
        });
*/
});
//curl -X POST -H "X-Parse-Application-Id: mxzbQxv3lYPBJoOpbnkMDgnDoFFkFuUW6Sm3Of9d" -H "X-Parse-REST-API-Key: v4uFmG5hgfhJKejsDqLBRFbq15gWBxnA6yZd9Dvm" -H "Content-Type: application/json" -d '{"toEmail":"bobbyren@gmail.com","toName":"Bobby Ren","fromEmail":"bobbyren@gmail.com","fromName":"Bobby Ren","text":"testing ManDrill email","subject":"this is just a test"}' https://api.parse.com/1/functions/sendMail