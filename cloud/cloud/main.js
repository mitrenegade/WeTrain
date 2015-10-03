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

var sendPushTrainingRequest = function(clientId, requestId) {
    console.log("inside send push")
    Parse.Push.send({
                    channels: [ "Trainers" ],
                    data: {
                    alert: "New training request available.",
                    badge: "Increment",
                    client: clientId,
                    request: requestId
                    }
                    }, {
                    success: function() {
                    // Push was successful
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

Parse.Cloud.define("sendMail", function(request, response) {
                   sendMail(request, response)
                   });

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

Parse.Cloud.beforeSave("TrainingRequest", function(request, response) {
                        var trainingObject = request.object
                       
                        if (trainingObject.get("passcode") == undefined) {
                            trainingObject.set("passcode", randomPasscode())
                            console.log("added passcode " + trainingObject.get("passcode") + " to training object " + trainingObject.id)
                        }
                       response.success()
                       });

Parse.Cloud.afterSave("TrainingRequest", function(request) {
                      var trainingObject = request.object
                      console.log("TrainingRequest id: " + trainingObject.id )
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

                      var text = "TrainingRequest id: " + trainingObject.id + " Status: " + status + "\nLat: " + trainingObject.get("lat") + " Lon: " + trainingObject.get("lon") + "\nTime: " + trainingObject.get("time")
                      
                      var clientObject = request.object.get("client")
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
                                      console.log("visit by user " + email)
                                      sendMail(email, fromName, text, subject)
                                      
                                      // send push notification
                                      if (status == "requested") {
                                        console.log("Client object: " + clientObject + " id: " + clientObject.id)
                                        console.log("Training object: " + trainingObject + " id: " + trainingObject.id)
                                        sendPushTrainingRequest(clientObject.id, trainingObject.id)
                                      
                                        }
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

//curl -X POST -H "X-Parse-Application-Id: mxzbQxv3lYPBJoOpbnkMDgnDoFFkFuUW6Sm3Of9d" -H "X-Parse-REST-API-Key: v4uFmG5hgfhJKejsDqLBRFbq15gWBxnA6yZd9Dvm" -H "Content-Type: application/json" -d '{"toEmail":"bobbyren@gmail.com","toName":"Bobby Ren","fromEmail":"bobbyren@gmail.com","fromName":"Bobby Ren","text":"testing ManDrill email","subject":"this is just a test"}' https://api.parse.com/1/functions/sendMail