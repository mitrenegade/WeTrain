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
        
    }

    @IBAction func didClickAddPhoto(sender: UIButton) {
        
    }
    
    @IBAction func didClickSignup(sender: UIButton) {
        let firstName = self.inputFirstName.text
        if firstName?.characters.count == 0 {
            self.simpleAlert("Please enter your first name", message: nil)
            return
        }
        let lastName: String? = self.inputLastName.text

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

        // create trainer object
        var trainerDict = ["firstName": firstName!, "email": email!, "phone": phone!];
        if lastName != nil {
            trainerDict["lastName"] = lastName!
        }
        let trainerObject: PFObject = PFObject(className: "Trainer", dictionary: trainerDict)
        trainerObject.setObject(user!, forKey: "user")
        trainerObject.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                self.simpleAlert("Error creating trainer", message: "We could not create your trainer profile.", completion: nil)
                return
            }
            else {
                user?.setObject(trainerObject, forKey: "trainer")
                user?.saveInBackgroundWithBlock({ (success, error) -> Void in
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
