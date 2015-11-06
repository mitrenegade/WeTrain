//
//  TrainerProfileViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/4/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class TrainerProfileViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonMeet: UIButton!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var labelInfo: UILabel!

    @IBOutlet weak var constraintInfoHeight: NSLayoutConstraint!
    
    var trainer: PFObject?
    var request: PFObject?
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.photoView.layer.borderWidth = 2
        self.photoView.layer.borderColor = UIColor(red: 112/255.0, green: 150/255.0, blue: 67/255.0, alpha: 1).CGColor
        self.photoView.layer.cornerRadius = 5
        
        self.buttonMeet.layer.cornerRadius = 5

        self.viewInfo.layer.borderWidth = 1
        self.viewInfo.layer.borderColor = UIColor(red: 112/255.0, green: 150/255.0, blue: 67/255.0, alpha: 1).CGColor
        self.viewInfo.layer.cornerRadius = 5
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: "promptForCancel")
        
        trainer?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            self.updateTrainerInfo()
            
            let status = self.request!.objectForKey("status") as! String
            if status == RequestState.Matched.rawValue || status == RequestState.Training.rawValue {
                // start a timer
                if self.timer == nil {
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateRequestState", userInfo: nil, repeats: true)
                    self.timer?.fire()
                }
            }
        })

        self.setTitleBarColor(UIColor.blackColor(), tintColor: UIColor.whiteColor())
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTrainerInfo() {
        if let file = self.trainer!.objectForKey("photo") as? PFFile {
            file.getDataInBackgroundWithBlock { (data, error) -> Void in
                if data != nil {
                    let photo: UIImage = UIImage(data: data!)!
                    self.photoView.image = photo
                }
            }
        }
        let firstName = self.trainer!.objectForKey("firstName") as? String
        let lastName = self.trainer!.objectForKey("lastName") as? String
        self.labelName.text = firstName!
        if lastName != nil {
            self.labelName.text = "\(firstName!) \(lastName!)"
        }
  
        var infoText = ""
        if let bio: String = self.trainer!.objectForKey("bio") as? String {
            infoText = "About \(firstName!): \n\n\(bio)\n\n"
        }
        
        let status: String = self.request!.objectForKey("status") as! String
        if status == RequestState.Cancelled.rawValue {
            if firstName != nil {
                infoText = "\(firstName!) cancelled the workout."
            }
            else {
                infoText = "Your trainer cancelled the workout."
            }
        }
        if status == RequestState.Matched.rawValue {
            let passcode: String = self.request!.objectForKey("passcode") as! String
            infoText = "\(infoText)Tell your trainer the passcode for today's workout:\n\(passcode.uppercaseString)"
            
        }
        self.labelInfo.text = infoText
/*
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!])
        let string = text as NSString
        var range = string.rangeOfString("Credentials:")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 16)!, range: range)
        range = string.rangeOfString("Specialty:")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 16)!, range: range)
        range = string.rangeOfString("Estimated Time of Arrival:")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 16)!, range: range)
        
        self.labelInfo.attributedText = attributedString
*/
        let size = self.labelInfo.sizeThatFits(CGSize(width: self.labelInfo.frame.size.width, height: self.viewInfo.frame.size.height - 20))
        self.constraintInfoHeight.constant = size.height
        
    }
    
    @IBAction func didClickButton(button: UIButton) {
        let status: String = self.request!.objectForKey("status") as! String
        if status == RequestState.Matched.rawValue {
            self.contact()
        }
        else if status == RequestState.Complete.rawValue {
            self.close()
        }
        else if status == RequestState.Training.rawValue {
            self.promptForCancel()
        }
        else if status == RequestState.Cancelled.rawValue {
            self.contact()
        }
    }
    
    func close() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func promptForCancel() {
        var title = "End session?"
        var buttonTitle = "End session"
        var message = "You seem to be in a training session. Do you want to end it?"
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
            alert.addAction(UIAlertAction(title: "Contact Trainer", style: .Default, handler: { (action) -> Void in
                self.contact()
            }))
        }
        alert.addAction(UIAlertAction(title: "Go Back", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func contact() {
        let name = self.trainer!.objectForKey("firstName") as! String
        var phone: String = ""
        if let phonenum: String = self.trainer!.objectForKey("phone") as? String {
            phone = phonenum.stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "").stringByReplacingOccurrencesOfString("-", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        }
        else {
            self.simpleAlert("Could not contact client", message: "The number we had for \(name) was invalid.")
            return
        }
        if (MFMessageComposeViewController.canSendText() == true) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alert.view.tintColor = UIColor.blackColor()
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
            if !UIApplication.sharedApplication().openURL(url!) {
                self.simpleAlert("Could not contact client", message: "We could not call the number \(phone).")
            }
            return
        }
        self.simpleAlert("Could not contact client", message: "We could not call the number \(phone).")
    }
    
    // MARK: - Message composer delegate
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }

    func updateRequestState() {
        self.request!.fetchInBackgroundWithBlock({ (object, error) -> Void in
            self.refreshState()
        })
    }
    
    func refreshState() {
        let status: String = self.request!.objectForKey("status") as! String
        if status == RequestState.Matched.rawValue {
            let firstName = self.trainer!.objectForKey("firstName") as! String
            self.buttonMeet.setTitle("Contact \(firstName)", forState: .Normal)
            self.buttonMeet.enabled = true
        }
        else if status == RequestState.Training.rawValue {
            self.buttonMeet.setTitle("Workout In Progress", forState: .Normal)
            self.buttonMeet.enabled = true
        }
        else if status == RequestState.Complete.rawValue {
            self.buttonMeet.setTitle("Workout Complete", forState: .Normal)
            self.buttonMeet.enabled = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
           
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
        else if status == RequestState.Cancelled.rawValue {
            // trainer cancelled
            let firstName = self.trainer!.objectForKey("firstName") as! String
            self.buttonMeet.setTitle("Contact \(firstName)", forState: .Normal)
            self.buttonMeet.enabled = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
            
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
        
        self.updateTrainerInfo()
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
