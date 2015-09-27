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
    let TRAINING_ICONS = ["exercise_healthyHeart", "exercise_lipo", "exercise_mobiFit", "exercise_blt", "exercise_bellyBusters", "exercise_trex", "exercise_sportsEndurance", "exercise_shredFactory"]
    
    var selectedExerciseType: Int?
    var selectedExerciseLength: Int?
    
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
        
        let alert = UIAlertController(title: "Select length", message: "Please select the training session length you want.", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "30 minutes", style: .Default, handler: { (action) -> Void in
            self.selectedExerciseType = indexPath.row
            self.selectedExerciseLength = 30
            self.goToMap()
        }))
        alert.addAction(UIAlertAction(title: "60 minutes", style: .Default, handler: { (action) -> Void in
            self.selectedExerciseType = indexPath.row
            self.selectedExerciseLength = 60
            self.goToMap()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:  { (action) -> Void in
            self.selectedExerciseType = nil
            self.selectedExerciseLength = nil
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func goToMap() {
        self.performSegueWithIdentifier("GoToMap", sender: self)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        let nav = segue.destinationViewController as! UINavigationController
        let controller = nav.viewControllers[0] as! MapViewController
        controller.requestedTrainingType = self.selectedExerciseType
        controller.requestedTrainingLength = self.selectedExerciseLength
    }

}
