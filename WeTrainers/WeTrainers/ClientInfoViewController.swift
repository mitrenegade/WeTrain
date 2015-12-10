//
//  ClientInfoViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 10/1/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse
import MessageUI

protocol ClientInfoDelegate: class {
    func clientsDidChange()
}

class ClientInfoViewController: UIViewController, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {

    var request: PFObject!
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var iconExercise: UIImageView!
    @IBOutlet weak var labelExercise: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var constraintLabelAddressHeight: NSLayoutConstraint?
    @IBOutlet weak var labelInfo: UITextView!

    @IBOutlet weak var viewPasscode: UIView!
    @IBOutlet weak var labelPasscode: UILabel!
    @IBOutlet weak var inputPasscode: UITextField!
    @IBOutlet weak var constraintPasscodeHeight: NSLayoutConstraint!
    
    @IBOutlet weak var buttonAction: UIButton!
    @IBOutlet weak var constraintButtonActionRight: NSLayoutConstraint!

    @IBOutlet weak var buttonContact: UIButton!
    @IBOutlet weak var constraintButtonContactHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintButtonContactTop: NSLayoutConstraint!
    @IBOutlet weak var constraintButtonContactLeft: NSLayoutConstraint!

    weak var delegate: ClientInfoDelegate?
    
    let trainer: PFObject = PFUser.currentUser()!.objectForKey("trainer") as! PFObject
    var client: PFObject?
    var status: String = "loading"
    
    var timerClock: NSTimer?
    var timerStatus: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoView.layer.borderWidth = 1
        self.photoView.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.photoView.layer.cornerRadius = self.photoView.frame.size.width/2

        self.viewInfo.layer.borderWidth = 1
        self.viewInfo.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.viewInfo.layer.cornerRadius = 5
        
        self.iconExercise.layer.borderWidth = 1
        self.iconExercise.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.iconExercise.layer.cornerRadius = 5
        
        self.constraintButtonContactHeight.constant = 0
        self.setTitleBarColor(UIColor.blackColor(), tintColor: UIColor.whiteColor())
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")

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
                
                if let file = self.client!.objectForKey("photo") as? PFFile {
                    file.getDataInBackgroundWithBlock { (data, error) -> Void in
                        if data != nil {
                            let photo: UIImage = UIImage(data: data!)!
                            self.photoView.image = photo
                        }
                    }
                }

                let exercise = self.request.objectForKey("type") as? String
                
                // TODO: use user photo instead for image
                let index = TRAINING_TITLES.indexOf(exercise!)
                if index != nil {
                    self.iconExercise.image = UIImage(named: TRAINING_ICONS[index!])!
                }
                else {
                    self.iconExercise.image = nil
                }
                
                if self.timerStatus == nil {
                    self.timerStatus = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateRequestState", userInfo: nil, repeats: true)
                    self.timerStatus?.fire()
                }

                self.status = self.request.objectForKey("status") as! String
                self.refreshState()
            })
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleGesture:")
        self.labelAddress.superview!.addGestureRecognizer(tap)
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
        let length = self.request.objectForKey("length") as? Int
        
        self.labelExercise.text = "Exercise: \(exercise!)"
        let index = TRAINING_TITLES.indexOf(exercise!)
        if index != nil {
            self.labelExercise.text = "\(self.labelExercise.text!) (\(TRAINING_SUBTITLES[index!]))"
        }
        
        var info: String = ""
        if length != nil {
            info = "Session length: \(length!) minutes"
            if length == 30 {
                info = "\(info)\nPrice: $11\n"
            }
            else {
                info = "\(info)\nPrice: $17\n"
            }
        }
        if self.status == RequestState.Training.rawValue || self.status == RequestState.Complete.rawValue {
            if let start = self.request.objectForKey("start") as? NSDate {
                let interval = NSDate().timeIntervalSinceDate(start)
                print("interval since workout started: \(interval)")
                let seconds = Int(interval % 60)
                let minutes = Int((interval / 60) % 60)
                let hours = Int((interval / 3600))
                let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                
                if self.status == RequestState.Complete.rawValue {
                    info = "\(info)Completed workout length: \(timeString)\n"
                }
                else {
                    info = "\(info)Time elapsed: \(timeString)\n"
                    
                    if self.timerClock == nil {
                        self.timerClock = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "tick", userInfo: nil, repeats: true)
                    }
                }
            }
        }
        else if self.status == RequestState.Matched.rawValue {
            var ago: String = ""
            if let time = request.objectForKey("time") as? NSDate {
                var minElapsed:Int = Int(NSDate().timeIntervalSinceDate(time) / 60)
                let hourElapsed:Int = Int(minElapsed / 60)
                minElapsed = Int(minElapsed) - Int(hourElapsed * 60)
                if minElapsed < 0 {
                    minElapsed = 0
                }
                if hourElapsed > 0 {
                    ago = "\(hourElapsed)hr"
                }
                else {
                    ago = ""
                }
                ago = "\(ago)\(minElapsed)min ago"
            }
            info = "\(info)Training Requested: \(ago)\n"
        }
        else if self.status == RequestState.Cancelled.rawValue {
            if let end = request.objectForKey("end") as? NSDate {
                var ago: String = ""
                var minElapsed:Int = Int(NSDate().timeIntervalSinceDate(end) / 60)
                let hourElapsed:Int = Int(minElapsed / 60)
                minElapsed = Int(minElapsed) - Int(hourElapsed * 60)
                if minElapsed < 0 {
                    minElapsed = 0
                }
                if hourElapsed > 0 {
                    ago = "\(hourElapsed)h"
                }
                else {
                    ago = ""
                }
                ago = "\(ago)\(minElapsed)m ago"
                info = "The training session was cancelled by the client \(ago)\n"
            }
            else {
                info = "The training session was cancelled by the client.\n"
            }
        }
        
        if gender != nil {
            info = "\(info)Gender: \(gender!)\n"
        }
        if age != nil {
            info = "\(info)Age: \(age!)\n"
        }
        if injuries != nil {
            info = "\(info)Injuries: \(injuries!)\n"
        }
        
        if self.request.objectForKey("trainer") != nil && (self.request.objectForKey("trainer") as! PFObject).objectId != self.trainer.objectId {
            info = "The client is already matched with a different trainer."
        }
        
        self.labelInfo.text = info
        
        if self.status == RequestState.Matched.rawValue || self.status == RequestState.Searching.rawValue {
            if let address: String = request.objectForKey("address") as? String {
                self.labelAddress.text = "Location: \(address)"
                let size = self.labelAddress.sizeThatFits(CGSize(width: self.labelAddress.frame.size.width, height: self.viewInfo.frame.size.height - 20))
                self.constraintLabelAddressHeight!.constant = size.height
            }
            else {
                self.constraintLabelAddressHeight!.constant = 0
            }
        }

        if self.request.objectForKey("trainer") != nil && (self.request.objectForKey("trainer") as! PFObject).objectId != self.trainer.objectId {
            self.constraintLabelAddressHeight!.constant = 0
        }

        self.labelInfo.contentOffset = CGPointZero
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
    
    func refreshState() {
        if self.status == "loading" {
            self.constraintPasscodeHeight.constant = 0
            self.buttonAction.setTitle("Loading", forState: .Normal)
            self.buttonAction.enabled = false
            self.constraintButtonContactHeight.constant = 0
        }
        else if self.status == RequestState.Searching.rawValue {
            self.constraintPasscodeHeight.constant = 0
            self.buttonAction.setTitle("Accept client", forState: .Normal)
            self.buttonAction.enabled = true
            self.constraintButtonContactHeight.constant = 0
        }
        else if self.status == RequestState.Matched.rawValue {
            self.constraintPasscodeHeight.constant = 45
            self.buttonAction.setTitle("Start workout", forState: .Normal)
            self.buttonAction.enabled = true
            self.constraintButtonContactHeight.constant = 40
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: "promptForCancel")
        }
        else if self.status == RequestState.Training.rawValue {
            self.constraintPasscodeHeight.constant = 0
            self.buttonAction.setTitle("Workout in progress", forState: .Normal)
            self.buttonAction.enabled = false
            self.constraintButtonContactHeight.constant = 0
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: "promptForCancel")
        }
        else if self.status == RequestState.Complete.rawValue {
            self.constraintPasscodeHeight.constant = 0
            self.buttonAction.setTitle("Workout complete", forState: .Normal)
            self.buttonAction.enabled = true
            self.constraintButtonContactHeight.constant = 0
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
        }
        else if self.status == RequestState.Cancelled.rawValue {
            // client cancelled while in Matched state
            self.constraintPasscodeHeight.constant = 0
            self.buttonAction.setTitle("Close", forState: .Normal)
            self.buttonAction.enabled = true
            self.constraintButtonContactHeight.constant = 40
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
        }
        
        if self.view.frame.size.height <= 480 {
            if self.constraintButtonContactHeight.constant == 0 {
                self.constraintButtonActionRight.constant = self.viewInfo.frame.size.width
            }
            else {
                self.constraintButtonContactTop.constant = -self.buttonAction.frame.size.height
                self.constraintButtonActionRight.constant = -self.viewInfo.frame.size.width / 2
                self.constraintButtonContactLeft.constant = self.viewInfo.frame.size.width / 2
            }
        }
        
        // another trainer stole it
        if self.request.objectForKey("trainer") != nil && (self.request.objectForKey("trainer") as! PFObject).objectId != self.trainer.objectId {
            self.constraintPasscodeHeight.constant = 0
            self.buttonAction.setTitle("Close", forState: .Normal)
            self.buttonAction.enabled = true
            self.constraintButtonContactHeight.constant = 0
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
        }

        self.updateLabelInfo()
    }
    
    func updateRequestState() {
        self.request!.fetchInBackgroundWithBlock({ (object, error) -> Void in
            self.status = self.request.objectForKey("status") as! String
            self.refreshState()
        })
    }
    
    @IBAction func didClickButton(sender: UIButton) {
        if sender == self.buttonContact {
            self.contact()
        }
        else {
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
            else if self.status == RequestState.Complete.rawValue || self.status == RequestState.Cancelled.rawValue {
                self.close()
            }
            else {
                self.refreshState()
            }
        }
    }
    
    func handleGesture(gesture: UIGestureRecognizer) {
        let touch = gesture.locationInView(self.labelAddress.superview!)
        if CGRectContainsPoint(self.labelAddress.frame, touch) {
            if let address: String = request.objectForKey("address") as? String {
                self.openInMaps(address)
                return
            }
        }
    }
    func openInMaps(address: String) {
        let escapedString = address.stringByReplacingOccurrencesOfString(" ", withString: "+")
        print("original \(address) escaped \(escapedString)")
        let url: NSURL? = NSURL(string: "comgooglemaps://?q=\(escapedString)")
        if url != nil && UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
        else {
            var message = "WeTrain could not open the map app for this address"
            if address.characters.count > 0 {
                message = "\(message): \(address)"
            }
            self.simpleAlert("Could not open Google Maps", message: message)
        }
    }
    
    func contact() {
        let name = self.client!.objectForKey("firstName") as! String
        var phone: String = ""
        if let phonenum: String = self.client!.objectForKey("phone") as? String {
            phone = phonenum.stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "").stringByReplacingOccurrencesOfString("-", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        }
        else {
            self.simpleAlert("Could not contact client", message: "The number we had for \(name) was invalid.")
            return
        }
        if (MFMessageComposeViewController.canSendText() == true) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Call \(name)", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.call(phone)
            }))
            alert.addAction(UIAlertAction(title: "Text \(name)", style: .Default, handler: { (action) -> Void in
                
                let composer = MFMessageComposeViewController()
                composer.recipients = [phone]
                composer.messageComposeDelegate = self
                self.presentViewController(composer, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.call(phone)
        }
    }
    
    func call(phone: String) {
        let str = "tel://\(phone)"
        let url = NSURL(string: str) as NSURL?
        if (url != nil) {
            UIApplication.sharedApplication().openURL(url!)
            return
        }
        self.simpleAlert("Could not contact client", message: "We could not call the number \(phone).")
    }

    // MARK: - Message composer delegate
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }

    func acceptTrainingRequest() {
        let trainerId: String = self.trainer.objectId! as String
        let params = ["workoutId": self.request.objectId!, "trainerId": trainerId]
        PFCloud.callFunctionInBackground("acceptWorkoutRequest", withParameters: params) { (results, error) -> Void in
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
                    self.refreshState()
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
        self.buttonAction.enabled = false
        let params: [String: AnyObject] = ["workoutId":self.request.objectId!, "clientId":self.client!.objectId!]
        PFCloud.callFunctionInBackground("startWorkout", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            if error != nil {
                // HACK: sending error objects back from parse cloud is a pain
                var message = "Please try again"
                if let userInfo: [String: AnyObject] = error!.userInfo as! [String: AnyObject] {
                    if let msg = userInfo["error"] {
                        message = "Error: \(msg)"
                    }
                }
                self.simpleAlert("Could not start workout", message:message)
                self.buttonAction.enabled = true
            }
            else {
                if let updatedWorkout: PFObject = results as! PFObject {
                    self.request = updatedWorkout
                    self.status = self.request.objectForKey("status") as! String
                    self.refreshState()
                    self.buttonAction.enabled = true
                }
                else {
                    self.request.fetchInBackgroundWithBlock({ (object, error) -> Void in
                        self.status = self.request.objectForKey("status") as! String
                        self.refreshState()
                        self.buttonAction.enabled = true
                    })
                }
            }
        }
    }
    
    func tick() {
        self.updateLabelInfo()
        
        if let start = self.request.objectForKey("start") as? NSDate {
            if let _ = self.request.objectForKey("end") as? NSDate {
                // if workout has ended but somehow we still have a timer, just end it
                self.refreshState()
                self.timerClock?.invalidate()
                self.timerClock = nil
                
                self.timerStatus?.invalidate()
                self.timerStatus = nil
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
        if self.timerClock != nil {
            self.timerClock?.invalidate()
            self.timerClock = nil
        }
        if self.timerStatus != nil {
            self.timerStatus?.invalidate()
            self.timerStatus = nil
        }
        
        self.request.setObject(RequestState.Complete.rawValue, forKey: "status")
        self.request.setObject(NSDate(), forKey: "end")
        self.trainer.removeObjectForKey("workout")
        self.request.saveInBackgroundWithBlock { (success, error) -> Void in
            self.status = self.request.objectForKey("status") as! String
            self.trainer.saveInBackgroundWithBlock({ (success, error) -> Void in
                self.refreshState()
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
    
    func promptForCancel() {
        // default state is Training
        var title = "End session?"
        var buttonTitle = "End session"
        var message = "You are currently in a training session. Do you want to end it?"
        let status: String = self.request!.objectForKey("status") as! String
        var newStatus: String = RequestState.Complete.rawValue
        if status == RequestState.Training.rawValue {
            if let start = self.request!.objectForKey("start") as? NSDate {
                if let _ = self.request!.objectForKey("end") as? NSDate {
                    // if workout has ended but somehow we still have a timer, just end it
                    self.close()
                    return
                }
                
                let interval = NSDate().timeIntervalSinceDate(start)
                let length = self.request!.objectForKey("length") as! NSNumber
                let minutes = Int(length) + 5
                if Int(interval) > 60*(minutes) {
                    message = "You seem to be in a training session that may have already ended. Do you want to close this session?"
                }
            }
        }
        else if status == RequestState.Matched.rawValue {
            // matched, but not started yet
            title = "Cancel session?"
            buttonTitle = "Cancel session"
            message = "Your session hasn't started yet. Do you want to cancel the session?"
            newStatus = RequestState.Cancelled.rawValue
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.view.tintColor = UIColor.blackColor()
        alert.addAction(UIAlertAction(title: buttonTitle, style: .Default, handler: { (action) -> Void in
            self.request!.setObject(newStatus, forKey: "status")
            self.request!.setObject(NSDate() , forKey: "end")
            self.request!.saveInBackgroundWithBlock({ (success, error) -> Void in
                self.close()
            })
        }))
        // give option to contact instead
        if status == RequestState.Matched.rawValue {
            alert.addAction(UIAlertAction(title: "Contact Client", style: .Default, handler: { (action) -> Void in
                self.contact()
            }))
        }
        alert.addAction(UIAlertAction(title: "Go Back", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
