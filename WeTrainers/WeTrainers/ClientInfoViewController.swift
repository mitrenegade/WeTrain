//
//  ClientInfoViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 10/1/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class ClientInfoViewController: UIViewController, UITextFieldDelegate {

    var request: PFObject!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var constraintLabelInfoHeight: NSLayoutConstraint?
    
    @IBOutlet weak var labelPasscode: UILabel!
    @IBOutlet weak var inputPasscode: UITextField!
    
    @IBOutlet weak var labelStart: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.imageView.layer.cornerRadius = 5

        self.viewInfo.layer.borderWidth = 1
        self.viewInfo.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.viewInfo.layer.cornerRadius = 5

        // Do any additional setup after loading the view.
        request.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            let clientObj: PFObject = self.request.objectForKey("client") as! PFObject
            clientObj.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                let firstName = clientObj.objectForKey("firstName") as? String
                let lastName = clientObj.objectForKey("lastName") as? String
                self.labelName.text = firstName!
                if lastName != nil {
                    self.labelName.text = "\(firstName!) \(lastName!)"
                }
                
                let exercise = self.request.objectForKey("type") as? String
                
                // TODO: use user photo instead for image
                let index = TRAINING_TITLES.indexOf(exercise!)
                if index != nil {
                    self.imageView.image = UIImage(named: TRAINING_ICONS[index!])!
                }
                else {
                    self.imageView.image = nil
                }
                
                let gender = clientObj.objectForKey("gender") as? String
                let age = self.ageOfClient(clientObj) as String?
                let injuries = clientObj.objectForKey("injuries") as? String

                var info = "Exercise: \(exercise!)"
                if gender != nil {
                    info = "\(info)\nGender: \(gender!)"
                }
                if age != nil {
                    info = "\(info)\nAge: \(age!)"
                }
                if injuries != nil {
                    info = "\(info)\nAge: \(injuries!)"
                }
                
                self.labelInfo.text = info
            })
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Done, target: self, action: "startWorkout")
        self.validatePasscode()
        self.labelStart.hidden = true;
    }
    
    func ageOfClient(client: PFObject) -> String? {
        // TODO: use birthdate to calculate age
        if let age = client.objectForKey("age") as? String {
            return age
        }
        else {
            return nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.inputPasscode.resignFirstResponder()
        
        self.validatePasscode()
        
        return true
    }
    
    func validatePasscode() {
        let text = self.inputPasscode.text
        
        if text?.lowercaseString == "lift" {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    func startWorkout() {
        self.labelStart.hidden = false
        self.labelPasscode.hidden = true
        self.inputPasscode.hidden = true
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
