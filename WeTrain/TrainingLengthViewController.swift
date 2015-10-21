//
//  TrainingLengthViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 10/19/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit

class TrainingLengthViewController: UIViewController {

    @IBOutlet weak var button30: UIButton!
    @IBOutlet weak var button60: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.button30.layer.cornerRadius = 5
        self.button60.layer.cornerRadius = 5
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
        let controller = segue.destinationViewController as! TrainingRequestViewController
        if sender != nil && sender! as! UIButton == self.button30 {
            controller.selectedExerciseLength = 30
        }
        else if sender != nil && sender! as! UIButton == self.button60 {
            controller.selectedExerciseLength = 60
        }
    }
}
