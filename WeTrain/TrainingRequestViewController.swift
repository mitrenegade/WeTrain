//
//  TrainingRequestViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class TrainingRequestViewController: UITableViewController {
    let TAG_ICON = 1
    let TAG_TITLE = 2
    let TAG_DETAILS = 3
    
    var selectedExerciseType: Int?
    var selectedExerciseLength: Int?
    
    var shouldHighlightEmergencyAlert: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.setTitleBarColor(UIColor.blackColor(), tintColor: UIColor.whiteColor())
        self.setTitleViewText("Select workout")
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
        print("row \(row) name \(name)")
        icon.image = UIImage(named: name)!//.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        icon.tintColor = UIColor(red: 215.0/255.0, green: 84.0/255.0, blue: 82.0/255.0, alpha: 1)
        labelTitle.text = TRAINING_TITLES[row]
        labelDetails.text = TRAINING_SUBTITLES[row]
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedExerciseType = indexPath.row
        self.performSegueWithIdentifier("GoToMap", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "GoToMap" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! MapViewController
            controller.requestedTrainingType = self.selectedExerciseType
            controller.requestedTrainingLength = self.selectedExerciseLength
        }
    }

}
