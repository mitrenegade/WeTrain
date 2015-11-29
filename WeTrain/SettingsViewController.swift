//
//  SettingsViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UITableViewController, TutorialDelegate, CreditCardDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 6
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let row = indexPath.row
        switch row {
        case 0:
            cell.textLabel!.text = "Edit your profile"
        case 1:
            cell.textLabel!.text = "Update your credit card"
        case 2:
            cell.textLabel!.text = "View tutorials"
        case 3:
            cell.textLabel!.text = "Feedback"
        case 4:
            cell.textLabel!.text = "Credits"
        case 5:
            cell.textLabel!.text = "Logout"
        default:
            break
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        switch row {
        case 0:
            if PFUser.currentUser() == nil {
                let alert: UIAlertController = UIAlertController(title: "Error editing profile", message: "You are not logged in. Please log in again to edit your profile.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.view.tintColor = UIColor.blackColor()
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            else {
                let controller: UserInfoViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("UserInfoViewController") as! UserInfoViewController
//                let nav: UINavigationController = UINavigationController(rootViewController: controller)
//                self.presentViewController:nav
                self.navigationController?.pushViewController(controller, animated: true)
            }
            break
        case 1:
            if PFUser.currentUser() == nil {
                let alert: UIAlertController = UIAlertController(title: "Error editing credit card", message: "You are not logged in. Please log in again to edit payment information.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.view.tintColor = UIColor.blackColor()
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            else {
                self.performSegueWithIdentifier("GoToCreditCard", sender: self)
            }
            
            break
        case 2:
            self.goToTutorials()
            break
        case 3:
            if PFUser.currentUser() == nil {
                let alert: UIAlertController = UIAlertController(title: "Log in first?", message: "You are not logged in. Please log in first so we can respond to you.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.view.tintColor = UIColor.blackColor()
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                }))
                alert.addAction(UIAlertAction(title: "Leave Anonymous Feedback", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                    self.performSegueWithIdentifier("GoToFeedback", sender: self)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("GoToFeedback", sender: self)
            }
            break
        case 4:
            let info = NSBundle.mainBundle().infoDictionary as [NSObject: AnyObject]?
            let version: AnyObject = info!["CFBundleShortVersionString"]!
            let message = "Copyright 2015 WeTrain, LLC\nVersion \(version)"
            self.simpleAlert("Credits", message: message)
            break
        case 5:
            self.appDelegate().logout()
        default:
            break
        }
    }
    
    func goToTutorials() {
        let controller: TutorialViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("TutorialViewController") as! TutorialViewController
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didCloseTutorial() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToCreditCard" {
            let nav: UINavigationController = segue.destinationViewController as! UINavigationController
            let controller: CreditCardViewController = nav.viewControllers[0] as! CreditCardViewController
            controller.delegate = self
        }
    }
    
    // MARK: - CreditCardDelegate
    func didSaveCreditCard(token: String) {
        if let client: PFObject = PFUser.currentUser()!.objectForKey("client") as? PFObject {
            // actually save credit card
            PFCloud.callFunctionInBackground("updatePayment", withParameters: ["clientId": client.objectId!, "stripeToken": token]) { (results, error) -> Void in
                print("results: \(results) error: \(error)")
                if error != nil {
                    var message = "Your credit card could not be updated. Please try again."
                    print("error: \(error)")
                    if let errorMsg: String = error!.userInfo["error"] as? String {
                        message = errorMsg
                    }
                    self.simpleAlert("Error saving credit card", message: message)
                }
            }
        }
    }
    
    func didCreateToken(token: String, lastFour: String) {
        self.simpleAlert("Invalid user", message: "Could not store your credit card info because your user is invalid. Please log out and log back in.")
    }

}
