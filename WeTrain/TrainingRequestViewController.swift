//
//  TrainingRequestViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit

class TrainingRequestViewController: UITableViewController {
    let TAG_ICON = 1
    let TAG_TITLE = 2
    let TAG_DETAILS = 3
    
    let TRAINING_TITLES = ["Healthy Heart", "Liposuction", "Mobi-Fit", "The BLT", "Belly Busters", "Tyrannosaurus Rex", "Sports Endurance", "The Shred Factory"]
    let TRAINING_SUBTITLES = ["Cardio", "Weight Loss", "Mobility", "Butt, Legs, Thighs", "Core", "Strength and Hypertrophy", "Muscular Endurance", "Toning"]
    let TRAINING_ICONS = ["exercise_healthyHeart", "exercise_lipo", "exercise_mobiFit", "exercise_bellyBusters", "exercise_trex", "exercise_sportsEndurance", "exercise_shredFactory"]
    
    var shouldHighlightEmergencyAlert: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.shouldHighlightEmergencyAlert = true
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
        return 8
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrainingRequestCell", forIndexPath: indexPath) as! UITableViewCell
        
        // Configure the cell...
        let icon: UIImageView = cell.contentView.viewWithTag(TAG_ICON) as! UIImageView
        let labelTitle: UILabel = cell.contentView.viewWithTag(TAG_TITLE) as! UILabel
        let labelDetails: UILabel = cell.contentView.viewWithTag(TAG_DETAILS) as! UILabel
        
        let row = indexPath.row
        let name = TRAINING_ICONS[row] as String
        icon.image = UIImage(named: name)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        icon.tintColor = UIColor(red: 215.0/255.0, green: 84.0/255.0, blue: 82.0/255.0, alpha: 1)
        labelTitle.text = TRAINING_TITLES[row]
        labelDetails.text = TRAINING_SUBTITLES[row]
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        if row == 2 {
            let alert = UIAlertController(title: "Call 911?", message: "Do you want to close WeTrain and call contact emergency services?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                self.shouldHighlightEmergencyAlert = false
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Call 911", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.call911()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.goToMap()
        }
    }

    func goToMap() {
        self.performSegueWithIdentifier("GoToMap", sender: self)
    }

    func call911() {
        var phone: String = "911"
        var str = "tel://\(phone)"
        let url = NSURL(string: str) as NSURL?
        if (url != nil) {
            let success: Bool = UIApplication.sharedApplication().openURL(url!)
            if success {
                return
            }
        }
        let alert = UIAlertController(title: "Could not call 911", message: "Close the app manually and call 911 if you need to.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
