var sendMail = function(text, subject) {
    var Mandrill = require('mandrill');
    Mandrill.initialize('aC8uXsVJlJHJw46uo8kTqA');
    
    Mandrill.sendEmail({
                       message: {
                       text: text,
                       subject: subject,
                       from_email: "bobbyren@gmail.com",
                       from_name: "DocPronto Team",
                       to: [
                            {
                            email: "sockol@wharton.upenn.edu",
                            name: "DocPronto Dispatch"
                            }
                            ]
                       },
                       async: true
                       },{
                       success: function(httpResponse) {
                       console.log(httpResponse);
                       },
                       error: function(httpResponse) {
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

                      var subject = "Feedback received"
                      var text = "Feedback id: " + feedback.id + "\nMessage: \n" + feedback.get("message")
                      sendMail(text, subject)

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
                      sendMail(text, subject)
                      
                      });

//curl -X POST -H "X-Parse-Application-Id: mxzbQxv3lYPBJoOpbnkMDgnDoFFkFuUW6Sm3Of9d" -H "X-Parse-REST-API-Key: v4uFmG5hgfhJKejsDqLBRFbq15gWBxnA6yZd9Dvm" -H "Content-Type: application/json" -d '{"toEmail":"bobbyren@gmail.com","toName":"Bobby Ren","fromEmail":"bobbyren@gmail.com","fromName":"Bobby Ren","text":"testing ManDrill email","subject":"this is just a test"}' https://api.parse.com/1/functions/sendMail