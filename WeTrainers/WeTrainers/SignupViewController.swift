//
//  SignupViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 9/24/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
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
        if self.inputFirstName.text?.characters.count == 0 {
            self.simpleAlert("Please enter an email address", message: nil)
            return
        }
        if self.inputPassword.text?.characters.count == 0 {
            self.simpleAlert("Please enter a password", message: nil)
            return
        }
        
        let email:NSString = self.inputLogin.text! as NSString
        if !email.isValidEmail() {
            self.simpleAlert("Please enter a valid email address", message: nil)
            return
        }
        
        let username = self.inputLogin.text
        let password = self.inputPassword.text
        
        let user = PFUser()
        user.username = username
        user.password = password
        
        if email.isValidEmail() {
            user.email = username
        }
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("signup succeeded")
                self.loggedIn()
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
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
