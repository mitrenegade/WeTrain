//
//  ClientInfoViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 10/1/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class ClientInfoViewController: UIViewController, UITextFieldDelegate {

    var request: PFObject!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var constraintLabelInfoHeight: NSLayoutConstraint?

    @IBOutlet weak var viewPasscode: UIView!
    @IBOutlet weak var labelPasscode: UILabel!
    @IBOutlet weak var inputPasscode: UITextField!
    
    @IBOutlet weak var buttonAction: UIButton!
    
    let trainer: PFObject = PFUser.currentUser()!.objectForKey("trainer") as! PFObject
    var status: String = "loading"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.imageView.layer.cornerRadius = 5

        self.viewInfo.layer.borderWidth = 1
        self.viewInfo.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.viewInfo.layer.cornerRadius = 5

        // Do any additional setup after loading the view.
        request.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            let clientObj: PFObject = self.request.objectForKey("client") as! PFObject
            clientObj.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                let firstName = clientObj.objectForKey("firstName") as? String
                let lastName = clientObj.objectForKey("lastName") as? String
                self.labelName.text = firstName!
                if lastName != nil {
                    self.labelName.text = "\(firstName!) \(lastName!)"
                }
                
                let exercise = self.request.objectForKey("type") as? String
                
                // TODO: use user photo instead for image
                let index = TRAINING_TITLES.indexOf(exercise!)
                if index != nil {
                    self.imageView.image = UIImage(named: TRAINING_ICONS[index!])!
                }
                else {
                    self.imageView.image = nil
                }
                
                let gender = clientObj.objectForKey("gender") as? String
                let age = self.ageOfClient(clientObj) as String?
                let injuries = clientObj.objectForKey("injuries") as? String

                var info = "Exercise: \(exercise!)"
                if gender != nil {
                    info = "\(info)\nGender: \(gender!)"
                }
                if age != nil {
                    info = "\(info)\nAge: \(age!)"
                }
                if injuries != nil {
                    info = "\(info)\nAge: \(injuries!)"
                }
                
                self.labelInfo.text = info
                
                self.status = self.request.objectForKey("status") as! String
                self.updateState()
            })
        }
        }
    
    func ageOfClient(client: PFObject) -> String? {
        // TODO: use birthdate to calculate age
        if let age = client.objectForKey("age") as? String {
            return age
        }
        else {
            return nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.inputPasscode.resignFirstResponder()
        
        self.validatePasscode()
        
        return true
    }
    
    func updateState() {
        if self.status == "loading" {
            self.viewPasscode.hidden = true
            self.buttonAction.setTitle("Loading", forState: .Normal)
            self.buttonAction.enabled = false
        }
        else if self.status == RequestState.Searching.rawValue {
            self.viewPasscode.hidden = true
            self.buttonAction.setTitle("Accept client", forState: .Normal)
            self.buttonAction.enabled = true
        }
        else if self.status == RequestState.Matched.rawValue {
            self.viewPasscode.hidden = false
            self.buttonAction.setTitle("Start workout", forState: .Normal)
            self.buttonAction.enabled = true
        }
        else if self.status == RequestState.Training.rawValue {
            self.viewPasscode.hidden = true
            self.buttonAction.setTitle("Workout in progress", forState: .Normal)
            self.buttonAction.enabled = false
        }
    }
    @IBAction func didClickButton(sender: UIButton) {
        let trainerId: String = self.trainer.objectId! as String
        if self.status == RequestState.Searching.rawValue {
            self.acceptTrainingRequest()
        }
        else if self.status == RequestState.Matched.rawValue && request.objectForKey("trainer")! as! String == trainerId {
            self.inputPasscode.resignFirstResponder()
            self.validatePasscode()
        }
    }
    
    func acceptTrainingRequest() {
        let trainerId: String = self.trainer.objectId! as String
        let params = ["trainingRequestId": self.request.objectId!, "trainerId": trainerId]
        PFCloud.callFunctionInBackground("acceptTrainingRequest", withParameters: params) { (results, error) -> Void in
            if error != nil {
                print("could not request training request")
                self.simpleAlert("Could not accept client", message: "The client's training session is no longer available.")
            }
            else {
                print("training session is yours")
                self.request.fetchInBackgroundWithBlock({ (object, error) -> Void in
                    self.status = self.request.objectForKey("status") as! String
                    self.updateState()
                })
            }
        }
    }
    
    func validatePasscode() {
        let text = self.inputPasscode.text
        let validCode = self.request.objectForKey("passcode") as? String
        
        if validCode == nil || text?.lowercaseString == validCode! {
            self.startWorkout()
        }
        else {
            self.simpleAlert("Invalid passcode", message: "Please enter the correct passcode given to you by your client.")
        }
    }
    
    func startWorkout() {
        self.request.setObject(RequestState.Training.rawValue, forKey: "status")
        self.request.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not start workout", message: "Please try again")
            }
            else {
                self.request.fetchInBackgroundWithBlock({ (object, error) -> Void in
                    self.status = self.request.objectForKey("status") as! String
                    self.updateState()
                })
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
