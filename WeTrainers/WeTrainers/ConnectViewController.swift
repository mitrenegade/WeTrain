//
//  ConnectViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 9/24/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class ConnectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ClientInfoDelegate {

    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var buttonAction: UIButton!
    @IBOutlet var buttonShift: UIButton!
    @IBOutlet var trainingRequests: [PFObject]?
    
    @IBOutlet var tableView: UITableView!
    
    var status: String?
    
    var shouldWarnIfRegisterPushFails: Bool = false // if user has denied push before, then registerForRemoteNotifications will not trigger a failure. Thus we have to manually warn after a certain time that the user needs to go to settings.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = PFUser.currentUser()!
        let trainer = user.objectForKey("trainer") as! PFObject
        status = trainer.objectForKey("status") as? String

        if status == "available" {
            // make a call to load any existing requests that we won't get through notifications because they were made already
            self.loadExistingRequestsWithCompletion({ (results) -> Void in
                if results == nil || results!.count == 0 {
                    if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
                        self.status = "disconnected"
                    }
                }
                self.refreshStatus()
                self.tableView.reloadData()
            })
        }
        
        // updates UI based on web
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
        self.updateStatus("off")
    }
    
    // MARK: - Status
    @IBAction func didClickButton(sender: UIButton) {
        // the status is made of two parts: the first part is what actually gets saved to parse, and the second part is a local status
        
        if sender == self.buttonShift {
            if self.status == "disconnected" {
                self.registerForRemoteNotifications()
            }
            else if self.status == "off" || self.status == nil {
                // start a shift
                self.updateStatus("available")
                self.loadExistingRequestsWithCompletion({ (results) -> Void in
                    self.refreshStatus()
                    self.tableView.reloadData()
                })
                self.buttonAction.hidden = false
            }
            else if self.status == "available" {
                // end a shift
                self.updateStatus("off")
            }
        }
        else if sender == self.buttonAction {
            if self.status == "disconnected" {
                // skip notifications
                let user = PFUser.currentUser()!
                let trainer = user.objectForKey("trainer") as! PFObject
                var actualStatus = trainer.objectForKey("status") as? String
                if actualStatus == nil {
                    actualStatus = "off"
                }
                self.updateStatus(actualStatus!)
            }
            else {
                self.loadExistingRequestsWithCompletion({ (results) -> Void in
                    self.refreshStatus()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func updateStatus(newStatus: String) {
        self.status = newStatus

        let statusString = newStatus as NSString
        let location = statusString.rangeOfString(".").location
        var trainerStatus = newStatus
        if location != NSNotFound {
            let index = newStatus.startIndex.advancedBy(location)
            trainerStatus = newStatus.substringToIndex(index)
        }
        
        let user = PFUser.currentUser()!
        let trainer = user.objectForKey("trainer") as! PFObject
        trainer.setObject(trainerStatus, forKey: "status")
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
        self.tableView.hidden = true
        
        if status == nil || status! == "off" {
            self.labelStatus.text = "Off duty"
            self.buttonShift.setTitle("Start shift", forState: .Normal)
            self.buttonAction.hidden = true
        }
        else if status == "disconnected" {
            self.labelStatus.text = "Notifications are not enabled"
            self.buttonShift.setTitle("Enable Notifications", forState: .Normal)
            self.buttonAction.setTitle("Remind me later", forState: .Normal)
            self.buttonAction.hidden = false
        }
        else if status == "available" {
            self.buttonAction.setTitle("Refresh list", forState: .Normal)
            self.buttonAction.hidden = false
            self.buttonShift.setTitle("End shift", forState: .Normal)
            if self.clientsAvailable() {
                self.labelStatus.text = "Clients available"
                self.tableView.hidden = false
            }
            else {
                self.labelStatus.text = "Waiting for client"
                self.tableView.hidden = true
            }
        }
    }
    
    func clientsAvailable() -> Bool {
        if self.trainingRequests == nil {
            return false
        }
        if self.trainingRequests!.count == 0 {
            return false
        }
        return true
    }

    // MARK: - Requests
    func didReceiveRequest(notification: NSNotification) {
        let userInfo = notification.userInfo as? [String: AnyObject]
        print("Sent info: \(userInfo!)")
        
        self.loadExistingRequestsWithCompletion { (results) -> Void in
            self.refreshStatus()
            self.tableView.reloadData()
        }
    }

    func loadExistingRequestsWithCompletion(completion: (results: [PFObject]?) -> Void) {
        let query = PFQuery(className: "TrainingRequest")
        // don't actually need to search for given training request - display all active requests
        query.whereKey("status", equalTo: "requested")
        query.whereKeyDoesNotExist("trainer")
        self.labelStatus.text = "Searching for clients"
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error != nil {
                print("could not query")
            }
            else {
                print("results: \(results!)")
                self.trainingRequests = results
            }
            
            completion(results: results!)
        }
    }
    
    // MARK: - TableViewDatasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.trainingRequests != nil {
        return self.trainingRequests!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TrainingRequestCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        let request: PFObject = self.trainingRequests![indexPath.row] as PFObject
        cell.setupWithRequest(request)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let request: PFObject = self.trainingRequests![indexPath.row] as PFObject
        self.connect(request)
    }
    
    func connect(request: PFObject) {
        // TODO:
        // attempt to update the request with current trainer information. check to make sure request hasn't been accepted.
        // do this on Parse Cloudcode.
        // if request successfully updates, set request status to accepted
        // start a workout.
        self.performSegueWithIdentifier("GoToClientRequest", sender: request)
    }
    
    // MARK: - ClientInfoDelegate
    func clientsDidChange() {
        self.loadExistingRequestsWithCompletion({ (results) -> Void in
            self.refreshStatus()
            self.tableView.reloadData()
        })
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToClientRequest" {
            let request = sender as! PFObject
            let controller = segue.destinationViewController as! ClientInfoViewController
            controller.request = request
            controller.delegate = self
        }
    }

}
