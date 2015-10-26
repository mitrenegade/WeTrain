//
//  TrainingLengthViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/19/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class TrainingLengthViewController: UIViewController {

    @IBOutlet weak var button30: UIButton!
    @IBOutlet weak var button60: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.button30.layer.cornerRadius = 5
        self.button60.layer.cornerRadius = 5

        // if there's a current request and we return to the app, go to that
        self.loadExistingRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToTrainingRequest" {
            let controller = segue.destinationViewController as! TrainingRequestViewController
            if sender != nil && sender! as! UIButton == self.button30 {
                controller.selectedExerciseLength = 30
            }
            else if sender != nil && sender! as! UIButton == self.button60 {
                controller.selectedExerciseLength = 60
            }
        }
        if segue.identifier == "GoToRequestState" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.viewControllers[0] as! RequestStatusViewController
            let client: PFObject = PFUser.currentUser()!.objectForKey("client") as! PFObject
            let request: PFObject = client.objectForKey("currentRequest") as! PFObject
            controller.currentRequest = request
        }
    }
    
    func loadExistingRequest() {
        let client: PFObject = PFUser.currentUser()!.objectForKey("client") as! PFObject
        if let request: PFObject = client.objectForKey("currentRequest") as? PFObject {
            request.fetchInBackgroundWithBlock({ (requestObject, error) -> Void in
                if let state = request.objectForKey("status") as? String {
                    print("state \(state) object \(requestObject)")
                    if state == RequestState.Matched.rawValue {
                        self.performSegueWithIdentifier("GoToRequestState", sender: nil)
                    }
                    else if state == RequestState.Searching.rawValue {
                        if let time = request.objectForKey("time") as? NSDate {
                            let minElapsed = NSDate().timeIntervalSinceDate(time) / 60
                            if Int(minElapsed) > 60 { // cancel after an hour
                                print("request cancelled")
                                request.setObject(RequestState.Cancelled.rawValue, forKey: "status")
                                request.saveInBackground()
                            }
                            else {
                                self.performSegueWithIdentifier("GoToRequestState", sender: nil)
                            }
                        }
                    }
                    else if state == RequestState.Training.rawValue {
                        if let start = request.objectForKey("start") as? NSDate {
                            let minElapsed = NSDate().timeIntervalSinceDate(start) / 60
                            let length = request.objectForKey("length") as! Int
                            print("started at \(start) time passed \(minElapsed) workout length \(length)")
                            if Int(minElapsed) > length {
                                print("completing training")
                                request.setObject(RequestState.Complete.rawValue, forKey: "status")
                                request.saveInBackground()
                            }
                            else {
                                self.performSegueWithIdentifier("GoToRequestState", sender: nil)
                            }
                        }
                    }
                }
            })
        }
    }

}
