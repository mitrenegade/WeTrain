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
    @IBOutlet var inputGender: UITextField!
    @IBOutlet var inputAge: UITextField!
    @IBOutlet var inputInjuries: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewScrollContent: UIView!
    @IBOutlet var constraintContentWidth: NSLayoutConstraint!
    @IBOutlet var constraintContentHeight: NSLayoutConstraint!
    
    @IBOutlet var constraintTopOffset: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "didSignup:")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.constraintContentWidth.constant = (self.appDelegate().window?.bounds.size.width)!
        self.constraintContentHeight.constant = self.inputInjuries.frame.origin.y + self.inputInjuries.frame.size.height + 50
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
/*
        let gender = self.inputGender.text
        if gender?.characters.count == 0 {
            self.simpleAlert("Please enter your gender", message: nil)
            return
        }

        let age = self.inputAge.text
        if age?.characters.count == 0 {
            self.simpleAlert("Please enter your age", message: nil)
            return
        }
*/
        // make sure user exists
        let user = PFUser.currentUser()
        if user == nil {
            self.simpleAlert("Invalid user", message: "You are not currently signed in. Please sign in again", completion: { () -> Void in
                self.appDelegate().goToLogin()
            })
        }

        // load existing trainer or create one
        var client: PFObject!
        if let clientObject: PFObject = PFUser.currentUser()!.objectForKey("client") as? PFObject {
            client = clientObject
            client.fetchInBackgroundWithBlock({ (object, error) -> Void in
                if error != nil {
                    self.simpleAlert("Error fetching your profile", message: "We could not load your profile to update it.", completion: nil)
                    return
                }
                else {
                    self.updateClientProfile(client)
                }
            })
        }
        else {
            client = PFObject(className: "Client")
            self.updateClientProfile(client)
        }
    }
    
    func updateClientProfile(client: PFObject) {
        // create trainer object
        var clientDict = ["firstName": self.inputFirstName.text!, "email": self.inputEmail.text!, "phone": self.inputPhone.text!];
        if self.inputLastName.text != nil {
            clientDict["lastName"] = self.inputLastName.text!
        }
        if self.inputAge.text != nil {
            clientDict["age"] = self.inputAge.text!
        }
        if self.inputGender.text != nil {
            clientDict["gender"] = self.inputGender.text!
        }
        if self.inputInjuries.text != nil {
            clientDict["injuries"] = self.inputInjuries.text!
        }
        client.setValuesForKeysWithDictionary(clientDict)
        let user = PFUser.currentUser()!
        client.setObject(user, forKey: "user")

        client.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                self.simpleAlert("Error creating profile", message: "We could not create your user profile.", completion: nil)
                return
            }
            else {
                user.setObject(client, forKey: "client")
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
