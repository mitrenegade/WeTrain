Parse.Cloud.define("sendMail", function(request, response) {
                   var Mandrill = require('mandrill');
                   Mandrill.initialize('aC8uXsVJlJHJw46uo8kTqA');
                   
                   Mandrill.sendEmail({
                                      message: {
                                      text: request.params.text,
                                      subject: request.params.subject,
                                      from_email: request.params.fromEmail,
                                      from_name: request.params.fromName,
                                      to: [
                                           {
                                           email: request.params.toEmail,
                                           name: request.params.toName
                                           }
                                           ]
                                      },
                                      async: true
                                      },{
                                      success: function(httpResponse) {
                                      console.log(httpResponse);
                                      response.success("Email sent!");
                                      },
                                      error: function(httpResponse) {
                                      console.error(httpResponse);
                                      response.error("Uh oh, something went wrong");
                                      }
                                      });
                   });


//curl -X POST -H "X-Parse-Application-Id: mxzbQxv3lYPBJoOpbnkMDgnDoFFkFuUW6Sm3Of9d" -H "X-Parse-REST-API-Key: v4uFmG5hgfhJKejsDqLBRFbq15gWBxnA6yZd9Dvm" -H "Content-Type: application/json" -d '{"toEmail":"bobbyren@gmail.com","toName":"Bobby Ren","fromEmail":"bobbyren@gmail.com","fromName":"Bobby Ren","text":"testing ManDrill email","subject":"this is just a test"}' https://api.parse.com/1/functions/sendMail