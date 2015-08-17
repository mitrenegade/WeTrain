//
//  SettingsViewController.swift
//  DocPronto
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UITableViewController {
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let row = indexPath.row
        switch row {
        case 0:
            cell.textLabel!.text = "About DocPronto"
        case 1:
            cell.textLabel!.text = "Update your credit card"
        case 2:
            cell.textLabel!.text = "Insurance"
        case 3:
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
            let info = NSBundle.mainBundle().infoDictionary as [NSObject: AnyObject]?
            let version: AnyObject = info!["CFBundleShortVersionString"]!
            let message = "Copyright 2015 Bobby Ren\nVersion \(version)"
            self.simpleAlert("About DocPronto", message: message)
            break
        case 1:
            if PFUser.currentUser() == nil {
                var alert: UIAlertController = UIAlertController(title: "Error editing credit card", message: "You are not logged in. Please log in again to edit payment information.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            else {
                self.performSegueWithIdentifier("GoToCreditCard", sender: self)
            }
            
            break;
        case 3:
            appDelegate.logout()
        default:
            break
        }
    }
    
    func simpleAlert(title: String?, message: String?) {
        var alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
