//
//  LoginViewController.swift
//  DocPronto
//
//  Created by Bobby Ren on 8/2/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var inputLogin: UITextField!
    @IBOutlet var inputPassword: UITextField!
    @IBOutlet var buttonLogin: UIButton!
    @IBOutlet var buttonSignup: UIButton!
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        self.reset()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reset() {
        self.inputPassword.text = nil;

        self.inputLogin.superview!.layer.borderWidth = 1;
        self.inputLogin.superview!.layer.borderColor = UIColor.lightGrayColor().CGColor;
        self.inputPassword.superview!.layer.borderWidth = 1;
        self.inputPassword.superview!.layer.borderColor = UIColor.lightGrayColor().CGColor;
    }
    
    @IBAction func didClickLogin(sender: UIButton) {
        if count(self.inputLogin.text) == 0 {
            self.simpleAlert("Please enter a login email", message: nil)
            return
        }
        if count(self.inputPassword.text) == 0 {
            self.simpleAlert("Please enter a password", message: nil)
            return
        }
        
        let username = self.inputLogin.text
        let password = self.inputPassword.text
        PFUser.logInWithUsernameInBackground(username, password: password) { (user, error) -> Void in
            println("logged in")
            if user != nil {
                self.loggedIn()
            }
            else {
                let title = "Login error"
                var message: String?
                if error?.code == 100 {
                    message = "Please check your internet connection"
                }
                else if error?.code == 101 {
                    message = "Invalid email or password"
                }
                
                self.simpleAlert(title, message: message)
            }
        }
    }
    
    @IBAction func didClickSignup(sender: UIButton) {
        if count(self.inputLogin.text) == 0 {
            self.simpleAlert("Please enter an email address", message: nil)
            return
        }
        if count(self.inputPassword.text) == 0 {
            self.simpleAlert("Please enter a password", message: nil)
            return
        }
        
        let email:NSString = self.inputLogin.text as NSString
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
                println("signup succeeded")
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
    
    func loggedIn() {
        appDelegate.didLogin()
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func simpleAlert(title: String?, message: String?) {
        var alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
