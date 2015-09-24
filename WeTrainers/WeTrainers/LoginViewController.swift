//
//  LoginViewController.swift
//  WeTrainers
//
//  Created by Bobby Ren on 9/24/15.
//  Copyright © 2015 Bobby Ren. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if self.inputLogin.text?.characters.count == 0 {
            self.simpleAlert("Please enter a userame", message: nil)
            return
        }
        if self.inputPassword.text?.characters.count == 0 {
            self.simpleAlert("Please enter a password", message: nil)
            return
        }
        
        let username: String = self.inputLogin.text!
        let password: String = self.inputPassword.text!
        PFUser.logInWithUsernameInBackground(username, password: password) { (user, error) -> Void in
            print("logged in")
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
                    message = "Invalid username or password"
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
