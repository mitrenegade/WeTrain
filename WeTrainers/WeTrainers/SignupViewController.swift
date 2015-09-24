//
//  SignupViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 9/24/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var inputFirstName: UITextField!
    @IBOutlet var inputLastName: UITextField!
    @IBOutlet var inputEmail: UITextField!
    @IBOutlet var inputPhone: UITextField!
    
    @IBOutlet var buttonAddPhoto: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "didSignup:")

    }

    @IBAction func didClickAddPhoto(sender: UIButton) {
        
    }
    
    func didSignup(sender: AnyObject) {
        let firstName = self.inputFirstName.text
        if firstName?.characters.count == 0 {
            self.simpleAlert("Please enter your first name", message: nil)
            return
        }

        let email = self.inputEmail.text
        if email?.characters.count == 0 {
            self.simpleAlert("Please enter an email", message: nil)
            return
        }
        if !self.isValidEmail(email!) {
            self.simpleAlert("Please enter a valid email address", message: nil)
            return
        }

        let phone = self.inputPhone.text
        if phone?.characters.count == 0 {
            self.simpleAlert("Please enter a valid phone number", message: nil)
            return
        }

        // make sure user exists
        let user = PFUser.currentUser()
        if user == nil {
            self.simpleAlert("Invalid user", message: "You are not currently signed in. Please sign in again", completion: { () -> Void in
                self.appDelegate().goToLogin()
            })
        }

        // load existing trainer or create one
        var trainer: PFObject!
        if let trainerObject: PFObject = PFUser.currentUser()!.objectForKey("trainer") as? PFObject {
            trainer = trainerObject
            trainer.fetchInBackgroundWithBlock({ (object, error) -> Void in
                if error != nil {
                    self.simpleAlert("Error fetching trainer", message: "We could not load your trainer profile to update it.", completion: nil)
                    return
                }
                else {
                    self.updateTrainerProfile(trainer)
                }
            })
        }
        else {
            trainer = PFObject(className: "Trainer")
            self.updateTrainerProfile(trainer)
        }
    }
    
    func updateTrainerProfile(trainer: PFObject) {
        // create trainer object
        var trainerDict = ["firstName": self.inputFirstName.text!, "email": self.inputEmail.text!, "phone": self.inputPhone.text!];
        if self.inputLastName.text != nil {
            trainerDict["lastName"] = self.inputLastName.text!
        }
        trainer.setValuesForKeysWithDictionary(trainerDict)
        let user = PFUser.currentUser()!
        trainer.setObject(user, forKey: "user")

        trainer.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                self.simpleAlert("Error creating trainer", message: "We could not create your trainer profile.", completion: nil)
                return
            }
            else {
                user.setObject(trainer, forKey: "trainer")
                user.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        print("signup succeeded")
                        self.appDelegate().didLogin()
                    }
                    else {
                        let title = "Signup error"
                        var message: String?
                        if error?.code == 100 {
                            message = "Please check your internet connection"
                        }
                        else if error?.code == 202 {
                            message = "Username already taken"
                        }
                        
                        self.simpleAlert(title, message: message)
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
