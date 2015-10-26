//
//  ClientInfoViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 10/1/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

protocol ClientInfoDelegate: class {
    func clientsDidChange()
}

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
    weak var delegate: ClientInfoDelegate?
    
    let trainer: PFObject = PFUser.currentUser()!.objectForKey("trainer") as! PFObject
    var client: PFObject?
    var status: String = "loading"
    
    var timer: NSTimer?

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
            self.client = self.request.objectForKey("client") as! PFObject
            self.client!.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                let firstName = self.client!.objectForKey("firstName") as? String
                let lastName = self.client!.objectForKey("lastName") as? String
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

    func updateLabelInfo() {
        let exercise = self.request.objectForKey("type") as? String
        let gender = self.client!.objectForKey("gender") as? String
        let age = self.ageOfClient(self.client!) as String?
        let injuries = self.client!.objectForKey("injuries") as? String
        
        var info = "Exercise: \(exercise!)"
        if self.status == RequestState.Training.rawValue || self.status == RequestState.Complete.rawValue {
            if let start = self.request.objectForKey("start") as? NSDate {
                let interval = NSDate().timeIntervalSinceDate(start)
                print("interval since workout started: \(interval)")
                let seconds = Int(interval % 60)
                let minutes = Int((interval / 60) % 60)
                let hours = Int((interval / 3600))
                let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                
                if self.status == RequestState.Complete.rawValue {
                    info = "\(info)\nTotal time elapsed: \(timeString)"
                }
                else {
                    info = "\(info)\nTime elapsed: \(timeString)"

                    if self.timer == nil {
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "tick", userInfo: nil, repeats: true)
                    }
                }
            }
        }
        if gender != nil {
            info = "\(info)\n\nGender: \(gender!)"
        }
        if age != nil {
            info = "\(info)\nAge: \(age!)"
        }
        if injuries != nil {
            info = "\(info)\nInjuries: \(injuries!)"
        }
        
        self.labelInfo.text = info
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
        else if self.status == RequestState.Complete.rawValue {
            self.viewPasscode.hidden = true
            self.buttonAction.setTitle("Complete workout", forState: .Normal)
            self.buttonAction.enabled = true
        }
        
        self.updateLabelInfo()
    }
    @IBAction func didClickButton(sender: UIButton) {
        if self.status == RequestState.Searching.rawValue {
            self.acceptTrainingRequest()
        }
        else if self.status == RequestState.Matched.rawValue {
            let trainer = request.objectForKey("trainer") as! PFObject
            if trainer.objectId == self.trainer.objectId {
                self.inputPasscode.resignFirstResponder()
                self.validatePasscode()
            }
            else {
                self.simpleAlert("Could not start workout", message: "The client's training session is no longer available.", completion: { () -> Void in
                    self.close()
                })
            }
        }
        else if self.status == RequestState.Complete.rawValue {
            self.close()
        }
        else {
            self.updateState()
        }
    }
    
    func acceptTrainingRequest() {
        let trainerId: String = self.trainer.objectId! as String
        let params = ["trainingRequestId": self.request.objectId!, "trainerId": trainerId]
        PFCloud.callFunctionInBackground("acceptTrainingRequest", withParameters: params) { (results, error) -> Void in
            if error != nil {
                print("could not request training request")
                self.simpleAlert("Could not accept client", message: "The client's training session is no longer available.", completion: { () -> Void in
                    self.close()
                })
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
        
        if validCode == nil || text?.lowercaseString == validCode!.lowercaseString {
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
    
    func tick() {
        self.updateLabelInfo()
        
        if let start = self.request.objectForKey("start") as? NSDate {
            if let _ = self.request.objectForKey("end") as? NSDate {
                // if workout has ended but somehow we still have a timer, just end it
                self.updateState()
                self.timer?.invalidate()
                self.timer = nil
                return
            }
            
            let interval = NSDate().timeIntervalSinceDate(start)
            let length = self.request.objectForKey("length") as! NSNumber
            let minutes = Int(length) + 5
            if Int(interval) > 60*(minutes) {
                self.endWorkout()
            }
        }
    }
    
    func endWorkout() {
        self.request.setObject(RequestState.Complete.rawValue, forKey: "status")
        self.request.setObject(NSDate(), forKey: "end")
        self.trainer.removeObjectForKey("workout")
        self.request.saveInBackgroundWithBlock { (success, error) -> Void in
            self.status = self.request.objectForKey("status") as! String
            self.trainer.saveInBackgroundWithBlock({ (success, error) -> Void in
                self.updateState()
            })
        }
        print("end workout")
    }

    func close() {
        if self.delegate != nil {
            self.delegate!.clientsDidChange()
        }
        self.navigationController!.popViewControllerAnimated(true)
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
