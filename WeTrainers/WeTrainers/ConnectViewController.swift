//
//  ConnectViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 9/24/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class ConnectViewController: UIViewController {

    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var buttonAction: UIButton!
    
    var status: String?
    
    var shouldWarnIfRegisterPushFails: Bool = false // if user has denied push before, then registerForRemoteNotifications will not trigger a failure. Thus we have to manually warn after a certain time that the user needs to go to settings.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            self.status = "disconnected"
        }
        else {
            let user = PFUser.currentUser()!
            let trainer = user.objectForKey("trainer") as! PFObject
            status = trainer.objectForKey("status") as? String
        }
        self.refreshStatus()

        // listen for push enabled
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushEnabled", name: "push:enabled", object: nil)

        // listen for push failure
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "warnForRemoteNotificationRegistrationFailure", name: "push:enable:failed", object: nil)

        // listen for request notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveRequest:", name: "request:received", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForRemoteNotifications() {
        let alert = UIAlertController(title: "Enable push notifications?", message: "To receive client notifications you must enable push. In the next popup, please click Yes.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            self.shouldWarnIfRegisterPushFails = true
            self.buttonAction.enabled = false
            self.buttonAction.alpha = 0.5
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                if self.shouldWarnIfRegisterPushFails {
                    self.warnForRemoteNotificationRegistrationFailure()
                }
            }
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func warnForRemoteNotificationRegistrationFailure() {
        self.shouldWarnIfRegisterPushFails = false
        self.buttonAction.enabled = true
        self.buttonAction.alpha = 1
        self.labelStatus.text = "Notifications are disabled"
        let alert = UIAlertController(title: "Change notification settings?", message: "Push notifications are disabled, so you can't receive client requests. Would you like to go to the Settings to update them?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            print("go to settings")
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pushEnabled() {
        self.buttonAction.enabled = true
        self.buttonAction.alpha = 1
        self.shouldWarnIfRegisterPushFails = false
        self.refreshStatus()
    }
    
    // MARK: - Status
    @IBAction func didClickButton(sender: UIButton) {
        if self.status == "disconnected" {
            self.registerForRemoteNotifications()
        }
        else if self.status == "off" || self.status == nil {
            // start a shift
            self.updateStatus("available")
        }
        else if self.status == "available" {
            // end a shift
            self.updateStatus("off")
        }
        else if self.status == "connecting" {
            self.updateStatus("training")
        }
        else if self.status == "training" {
            self.updateStatus("available")
        }
    }
    
    func updateStatus(newStatus: String) {
        self.status = newStatus
        
        let user = PFUser.currentUser()!
        let trainer = user.objectForKey("trainer") as! PFObject
        trainer.setObject(self.status!, forKey: "status")
        trainer.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.refreshStatus()
            }
            else {
                self.simpleAlert("Error", message: "Your status could not be updated. Please try again")
            }
        })
    }
    
    func refreshStatus() {
        if status == nil || status! == "off" {
            self.labelStatus.text = "Off duty"
            self.buttonAction.setTitle("Start shift", forState: .Normal)
        }
        else if status == "disconnected" {
            self.labelStatus.text = "Notifications are not enabled"
            self.buttonAction.setTitle("Enable Notifications", forState: .Normal)
        }
        else if status == "available" {
            self.labelStatus.text = "Waiting for client"
            self.buttonAction.setTitle("Go off duty", forState: .Normal)
        }
        else if status == "connecting" {
            self.labelStatus.text = "A client is available"
            self.buttonAction.setTitle("Accept training request", forState: .Normal)
        }
        else if status == "training" {
            self.labelStatus.text = "Training session"
            self.buttonAction.setTitle("Complete workout", forState: .Normal)
        }
    }

    // MARK: - Requests
    func didReceiveRequest(notification: NSNotification) {
        let userInfo = notification.userInfo as? [String: AnyObject]
        print("Sent info: \(userInfo!)")

        let requestId = userInfo?["requestId"] as? String
        // TODO: get request data from Parse
        
        if self.status == "available" {
            self.status = "connecting"
        }
        self.refreshStatus()
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
