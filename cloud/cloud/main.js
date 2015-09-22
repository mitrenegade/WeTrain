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
                            email: "sockol@wharton.upenn.edu",
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

Parse.Cloud.afterSave("VisitRequest", function(request) {
                      var visit = request.object
                      console.log("VisitRequest id: " + visit.id )
                      console.log("Lat: " + visit.get("lat") + " Lon: " + visit.get("lon"))
                      console.log("Time: " + visit.get("time"))
                      console.log("status: " + visit.get("status"))
                      
                      var subject = "Visit requested"
                      if (visit.get("status") == "none") {
                        subject = "Visit cancelled"
                      }
                      var text = "VisitRequest id: " + visit.id + " Status: " + visit.get("status") + "\nLat: " + visit.get("lat") + " Lon: " + visit.get("lon") + "\nTime: " + visit.get("time")

                      var userQuery = new Parse.Query("User");
                      userQuery.get(request.object.get("patient").id, {
                                    success: function(user) {
                                    email = user.get("email")
                                    fromName = "WeTrain Patient"
                                    if (email == undefined) {
                                        email = "bobbyren+WeTrain@gmail.com"
                                        fromName = "WeTrain Team"
                                    }
                                    console.log("visit by user " + email)
                                    sendMail(email, fromName, text, subject)
                                    },
                                    error : function(error) {
                                    console.error("errrrrrrrr" + error);
                                    email = "bobbyren+WeTrain@gmail.com"
                                    fromName = "WeTrain Team"
                                    sendMail(email, fromName, text, subject)
                                    }
                                    });
                      
                      });

//curl -X POST -H "X-Parse-Application-Id: mxzbQxv3lYPBJoOpbnkMDgnDoFFkFuUW6Sm3Of9d" -H "X-Parse-REST-API-Key: v4uFmG5hgfhJKejsDqLBRFbq15gWBxnA6yZd9Dvm" -H "Content-Type: application/json" -d '{"toEmail":"bobbyren@gmail.com","toName":"Bobby Ren","fromEmail":"bobbyren@gmail.com","fromName":"Bobby Ren","text":"testing ManDrill email","subject":"this is just a test"}' https://api.parse.com/1/functions/sendMail